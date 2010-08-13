package org.robotlegs.extentions.mvcs.macro
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
		 * The Dictionary of commands that we will be executing 
		 */		
		protected var commands:Array;
		
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
			commands = [];
			super();
		}
		
		/**
		 * Overrides the default execute method to kick off the execution of our commands 
		 */		
		override public function execute():void {
			super.execute();
		}
		
		/**
		 *  Creates a line item macro command object that will be added to the queue to be executed
		 * This class is only to be called in the initializeCommand function.
		 * @param command The class of the command that needs executing
		 * @param payload The payload (if any) that we want to pass to this command, usually an event
		 * @param named The named payload if there is one
		 * 
		 * 
		 */		
		protected function addCommand(command:Class, payload:Object = null, named:String = ""):void {
			// Wrap it all in an object so we can reference it easier through the code
			commands.push(new MacroItemDescriptor(command, payload, named));
		}	
		
		/**
		 * Executes the subcommand that is passed in, only will execute classes that inherit from AsyncCommand 
		 * @param cmd The object that contains the command information to execute
		 */		
		internal function executeSubcommand(cmd:MacroItemDescriptor):void {

			// Alternative method could be this, but then we can get a reference back to the command to listen
			// for a complete/incomplete callback or event
			//commandMap.execute(mappedCommand.command, mappedCommand.event, mappedCommand.payloadClass, mappedCommand.named);
			
			// If we have a payload, inject it in so that it will get injeted into the new command
			if(cmd.payload)
				injector.mapValue(cmd.payloadClass, cmd.payload, cmd.named);
			
			// Create an instance of the command
			var commandInstance:Object = injector.instantiate(cmd.command);
			
			// if we mapped a payload, unmap it
			if(cmd.payload)
				injector.unmap(cmd.payloadClass);
			
			// mark this as executed before we execute it just in case it is extra fast
			cmd.executed = true; 
			
			// If our command is an AsyncCommand
			if (commandInstance is AsyncCommand) 
			{
				// Cast it as an Async command, and add in our callback functions for complete/incomplete
				var asyncCommand:AsyncCommand = commandInstance as AsyncCommand;
				asyncCommand.onCommandComplete = subcommandComplete;
				asyncCommand.onCommandIncomplete = subcommandIncomplete;
				
				// Keep track of the containing object, because this is what keeps track of 
				// where this command is along the execution path of not started, started, completed, and completion status 
				asyncCommand.macroItemDescriptor = cmd;
				asyncCommand.execute();
			} else {
				// we got to a command instance, if it is a command execute it, mark it as a success
				commandInstance.execute();
				subcommandComplete(cmd);
			}
		}
		
		/**
		 * Called whenever a subcommand completes successfully 
		 * @param cmd the object containing the command that was executed
		 */		
		internal function subcommandComplete(cmd:MacroItemDescriptor):void {}
		
		/**
		 * Called whenever a subcommand completes unsuccessfully 
		 * @param cmd the object containing the command that was executed
		 */	
		internal function subcommandIncomplete(cmd:MacroItemDescriptor):void {} 
	}
}