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
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.robotlegs.mvcs.Command;

	public class MacroItemDescriptor
	{
		/**
		 * The class of the command that will be executed 
		 */		
		public var command:Class;
		
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
		 * Keeps track if the command has started execution yet 
		 */		
		internal var executed:Boolean;
		
		/**
		 * Keeps track if the command has finished exectution yet 
		 */		
		internal var executionFinished:Boolean;
		
		/**
		 * Keeps track if the command completed successfully or not 
		 */		
		internal var executedSuccessfully:Boolean;
		
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
		
		public function MacroItemDescriptor(command:Class, event:Object, named:String = ""):void
		{
			this.command = command;
			this.payload = event;
			this.named = named;
		}
	}
}