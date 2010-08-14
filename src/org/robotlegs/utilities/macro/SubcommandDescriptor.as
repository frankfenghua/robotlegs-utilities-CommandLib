/**
 *  Macro commands in the Robot Legs Framework
 * 
 * Any portion of this may be reused for any purpose where not 
 * licensed by another party restricting such use. 
 * 
 * Please leave the credits intact.
 * 
 * Chase Brammer
 * http://chasebrammer.com
 * cbrammer@gmail.com
 */

package org.robotlegs.utilities.macro
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.robotlegs.mvcs.Command;

	/**
	 * The available events that this class will dispatch 
	 */	
	[Event(name="subcommandStarted", type="org.robotlegs.utilities.macro.SubcommandExecutionStatusEvent")]
	[Event(name="subcommandCompleted", type="org.robotlegs.utilities.macro.SubcommandExecutionStatusEvent")]
	[Event(name="subcommandFailed", type="org.robotlegs.utilities.macro.SubcommandExecutionStatusEvent")]
	public class SubcommandDescriptor extends EventDispatcher
	{
		/**
		 * Indicates that the command has not yet been executed
		 */		
		public static const WAITING_TO_BE_EXECUTED:String = "waitingToBeExecuted";
		
		/**
		 * Indicates that the command is currently executing 
		 */		
		public static const IS_EXECUTING:String = "isExecuting";
		
		/**
		 * Indicates that the command finished executing, and did so successfully 
		 */		
		public static const EXECUTED_SUCCUSSFULLY:String = "executedSuccessfully";
		
		/**
		 * Indicates that the command finished executing, and did so unsuccessfully 
		 */		
		public static const EXECUTED_UNSUCCESSFULLY:String = "executedUnsuccessfully";
		
		/**
		 * The class of the command that will be executed 
		 */		
		public var command:Class;
		
		/**
		 * The class of the command that will be executed 
		 */		
		public var commandInstance:Object
		
		/**
		 * The payload object that will be injected into the command
		 * This is usually going to be an event 
		 */		
		public var payload:Object;
		
		/**
		 * The named value of the payload object, used in the RL framework
		 */		
		public var named:String;
		
		/**
		 * Keeps track of this descriptor's command's execution status
		 * available status are: waiting, executing, complete, incomplete 
		 */		
		private var _executionStatus:String
		
		/**
		 * Getter for the execution status 
		 * @return the execution status
		 */		
		public function get executionStatus():String {
			return _executionStatus;
		}

		/**
		 * Setter for the execution status, dispatches an event 
		 * informing any listeners of the status change 
		 * This is different that the setter, because we only want 
		 * internal classes to be able to set this value
		 * @param value
		 * 
		 */		
		internal function set executionStatus_internal(value:String):void {
			// only set the value if it is different
			if(value != _executionStatus) {
				
				_executionStatus = value;
				var eventType:String;
				
				// Go through and find the right event to dispatch that matches the new status
				switch(_executionStatus) {
					case IS_EXECUTING:
						eventType = SubcommandExecutionStatusEvent.SUBCOMMAND_STARTED;
						break;
					case EXECUTED_SUCCUSSFULLY:
						eventType = SubcommandExecutionStatusEvent.SUBCOMMAND_COMPLETED;
						break;
					case EXECUTED_UNSUCCESSFULLY:
						eventType = SubcommandExecutionStatusEvent.SUBCOMMAND_FAILED;
						break;
					default:
						// if we get to here, then it was a bad status, return out
						return;
				}
				
				// Create and dispatch the event
				var statusEvent:SubcommandExecutionStatusEvent = new SubcommandExecutionStatusEvent(eventType, this);
				dispatchEvent(statusEvent);
			}
		}

		/**
		 * Finds the payload class ref  
		 * @return Returns the class reference for the payload object 
		 */		
		public function get payloadClass():Class
		{
			if(!payload)
				return null;
			
			return getDefinitionByName(getQualifiedClassName(payload)) as Class;
		}
		
		public function SubcommandDescriptor(command:Class, payload:Object = null, named:String = ""):void
		{
			this.command = command;
			this.payload = payload;
			this.named = named;
			executionStatus_internal = WAITING_TO_BE_EXECUTED;
		}
	}
}