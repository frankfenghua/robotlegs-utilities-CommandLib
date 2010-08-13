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
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.mvcs.Command;

	public class ParallelCommand extends MacroCommand
	{
		
		public function ParallelCommand() {
			super();
		}
		
		/**
		 * Overrides the default execute method to kick off the execution of our commands 
		 */		
		override public function execute():void {
			super.execute();
			executeCommands();
		}
		
		/**
		 * Execute the next command available in our array of commands, if there are no
		 * commands left to execute, exits the batch 
		 */		
		private function executeCommands():void {
			for each(var cmd:MacroItemDescriptor in commands) {
				executeSubcommand(cmd);
			}
		}
		
		/**
		 * Called in a command fails 
		 * @param cmd the holding object that contains the command that was called
		 */		
		override internal function subcommandComplete(cmd:MacroItemDescriptor):void {
			cmd.executedSuccessfully = true;
			cmd.executionFinished = true;
			checkComplete();
		}
		
		/**
		 * Called in a command fails 
		 * @param cmd the holding object that contains the command that was called
		 */		
		override internal function subcommandIncomplete(cmd:MacroItemDescriptor):void {
			cmd.executedSuccessfully = false;
			cmd.executionFinished = true;
			checkComplete();
		}
		
		/**
		 * Goes through all of the commands and checks to see if they all finished 
		 * and if they did so successfuly, if they all finished then we will finish this AsyncCommand. 
		 */		
		private function checkComplete():void {
			var hasAtLeastOneFailure:Boolean;
			
			// Loop through all of the running commands and check if they
			// have been executed and if they failed or not
			for each (var cmd:MacroItemDescriptor in commands) {
				
				// exit this function if all commands have not yet been executed and completed
				if(!cmd.executed || !cmd.executionFinished)
					return;
				
				// check to see if we have a failure in the batch
				if(!hasAtLeastOneFailure && !cmd.executedSuccessfully)
					hasAtLeastOneFailure = true;
			}
			
			// No matter if we have a failure in the commands, since we started them all together, wait for 
			// them all to finish before saying we are complete or incomplete
			
			if(hasAtLeastOneFailure) {
				// If we have at least one item that failed, and we are not atomic then we failed, dispatch a command incomplete
				// but if we are atomic then who cares, we completed successfully
				isAtomic ? commandComplete() : commandIncomplete();
			} else {
				// no failures, everything executed successfully, we are complete
				commandComplete(); 
			}
		} 
	}
}