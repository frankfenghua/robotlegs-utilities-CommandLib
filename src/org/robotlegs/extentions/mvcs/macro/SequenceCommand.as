package org.robotlegs.extentions.mvcs.macro
{
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.mvcs.Command;

	public class SequenceCommand extends MacroCommand
	{
		public function SequenceCommand(commands:Array = null) {
			super(commands);
		}
		
		/**
		 * Overrides the default execute method to kick off the execution of our commands 
		 */		
		override public function execute():void {
			super.execute();
			executeNextCommand();
		}
		
		/**
		 * Execute the next command available in our array of commands, if there are no
		 * commands left to execute, exits the batch 
		 */		
		private function executeNextCommand():void
		{
			// Keep executing commands while we have commands in our array
			if(commands && commands.length > 0) {
				
				// The object holder for all of the info we need to execute each command
				var cmd:MacroCommandItemData = commands.shift();
				
				executeSubcommand(cmd); // Execute the subcommand
				
			} else {
				// Ok, we got done with all of our commands in the macro, tell any super macro's we are done
				commandComplete();
			}
		}
		
		/**
		 * Whenever a subcommand completes, its will call this function 
		 * @param cmd the MacroCommandItemData object that contained the command that was executed
		 */		
		override internal function subcommandComplete(cmd:MacroCommandItemData):void {
			cmd.executedSuccessfully = true; // mark it as completed succesfully
			executeNextCommand(); // run the next command
		}
		
		/**
		 * Whenever a subcommand fails, its will call this function 
		 * @param cmd the MacroCommandItemData object that contained the command that was executed
		 */		
		override internal function subcommandIncomplete(cmd:MacroCommandItemData):void {
			cmd.executedSuccessfully = false; // mark it as completed succesfully
			
			// If we failed, and we are not atomic then we failed, dispatch a command incomplete
			// but if we are atomic then who cares, go to the next command
			isAtomic ? executeNextCommand() : commandIncomplete();
		}
	}
}