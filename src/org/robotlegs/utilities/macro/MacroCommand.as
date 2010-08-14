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
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.mvcs.Command;

	internal class MacroCommand extends AsyncCommand
	{
		/**
		 * Keeps track each execution cycle if at least one command has failed
		 */		
		internal var hasAtLeastOneFailure:Boolean;
		
		/**
		 * The an array of command descriptors that contains what commands we will be executing
		 */		
		internal var commandDescriptors:Array;
		
		/**
		 * Determines if the commands are interdependant.  For example: if one command in a sequence fails
		 * then the whole batch fails and exits immediately.  If one command in the parallel fails, all will 
		 * finish executing, but the batch command itself will fail
		 * 
		 * isAtomic = true : This means they are NOT dependant on each other
		 * isAtomic = false : This means that they ARE dependant on each other
		 */		
		public var isAtomic:Boolean = true;
		
		public function MacroCommand()
		{
			hasAtLeastOneFailure = false;
			commandDescriptors = [];
			super();
		}
		
		/**
		 * Overrides the default execute method to kick off the execution of our commands 
		 */		
		override public function execute():void {
			super.execute();
		}
		
		
		/**
		 *  Creates a subcommand descriptor object that will be added to the queue to be executed
		 * @param command The class of the command that needs executing
		 * @param payload The payload (if any) that we want to pass to this command, usually an event
		 * @param named The named payload if there is one
		 * @return Returns a SubcommandDescriptor that can be used to listen to that status changes of each event
		 */		
		public function addCommand(command:Class, payload:Object = null, named:String = ""):SubcommandDescriptor {
			// Wrap it all in an object so we can reference it easier through the code
			var descriptor:SubcommandDescriptor = new SubcommandDescriptor(command, payload, named);
			commandDescriptors.push(descriptor);
			descriptor.executionStatus_internal = SubcommandDescriptor.WAITING_TO_BE_EXECUTED;
			return descriptor;
		}	
		
		/**
		 *  Creates a subcommand descriptor object that will be added to the queue to be executed,
		 * but takes a command instance clas
		 * @param commandInstance The instance of the class that needs some executing
		 * @param payload The payload (if any) that we want to pass to this command, usually an event
		 * @param named The named payload if there is one
		 * @return Returns a SubcommandDescriptor that can be used to listen to that status changes of each event
		 */		
		public function addProgramaticCommand(commandInstance:Object, payload:Object = null, named:String = ""):SubcommandDescriptor {
			// Get the type of class of the command instance that we passed in
			var commandClass:Class = getDefinitionByName(getQualifiedClassName(commandInstance)) as Class;
			
			// Wrap it all in an object so we can reference it easier through the code
			var descriptor:SubcommandDescriptor = new SubcommandDescriptor(commandClass, payload, named);
			
			descriptor.commandInstance_internal = commandInstance; // Add our instance to the descriptor
			commandDescriptors.push(descriptor); // Push it to the commands to be executed
			descriptor.executionStatus_internal = SubcommandDescriptor.WAITING_TO_BE_EXECUTED; // Set its status
			return descriptor;
		}	
		
		/**
		 * Executes the subcommand that is passed in, only will execute classes that inherit from AsyncCommand 
		 * @param cmd The object that contains the command information to execute
		 */		
		internal function executeSubcommand(cmd:SubcommandDescriptor):void {

			// Create an instance if we don't already have one
			if(!cmd.commandInstance) {
				
				// Alternative method could be this, but then we can get a reference back to the command to listen
				// for a complete/incomplete callback or event
				//commandMap.execute(mappedCommand.command, mappedCommand.event, mappedCommand.payloadClass, mappedCommand.named);
				
				// If we have a payload, inject it in so that it will get injeted into the new command
				if(cmd.payload)
					injector.mapValue(cmd.payloadClass, cmd.payload, cmd.named);
				
				// Create an instance of the command
				cmd.commandInstance_internal = injector.instantiate(cmd.commandClass);
				
				// if we mapped a payload, unmap it
				if(cmd.payload)
					injector.unmap(cmd.payloadClass);
			}
			
			// mark this as executed before we execute it just in case it is extra fast
			cmd.executionStatus_internal = SubcommandDescriptor.IS_EXECUTING; 
			
			// If our command is an AsyncCommand
			if (cmd.commandInstance is AsyncCommand) 
			{
				// Cast it as an Async command, and add in our callback functions for complete/incomplete
				var asyncCommand:AsyncCommand = cmd.commandInstance as AsyncCommand;
				asyncCommand.onCommandComplete = subcommandComplete;
				asyncCommand.onCommandIncomplete = subcommandIncomplete;
				
				// Keep track of the containing object, because this is what keeps track of 
				// where this command is along the execution path of not started, started, completed, and completion status 
				asyncCommand.macroItemDescriptor = cmd;
				asyncCommand.execute();
			} else {
				// we got to a command instance, if it is a command execute it, mark it as a success
				cmd.commandInstance.execute();
				subcommandComplete(cmd);
			}
		}
		
		/**
		 * Called whenever a subcommand completes successfully 
		 * Can be overridden by any class implemented MacroCommand to listen
		 * for when each subcommand is finished
		 * @param cmd the object containing the command that was executed
		 */		
		protected function subcommandComplete(cmd:SubcommandDescriptor):void {}
		
		/**
		 * Called whenever a subcommand completes unsuccessfully 
		 * Can be overridden by any class implemented MacroCommand to listen
		 * for when each subcommand is finished
		 * @param cmd the object containing the command that was executed
		 */	
		protected function subcommandIncomplete(cmd:SubcommandDescriptor):void {} 
	}
}