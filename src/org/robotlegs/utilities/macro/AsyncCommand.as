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
	import flash.utils.Dictionary;
	
	import org.robotlegs.base.EventMap;
	import org.robotlegs.core.IEventMap;
	import org.robotlegs.mvcs.Command;
	
	public class AsyncCommand extends Command
	{
		private var _onCommandComplete:Function;
		private var _onCommandIncomplete:Function;
		
		/**
		 * A variable that keeps lets the executing Async command know about
		 * the descriptor object that it belongs too 
		 */		
		internal var subcommandDescriptor_internal:SubcommandDescriptor;
		
		/**
		 * Allow the executing class to see this if they need it for any reason
		 * but do not allow them to copy it 
		 * @return the subcommand descriptor
		 * 
		 */		
		public function get subcommandDescriptor():SubcommandDescriptor {
			return subcommandDescriptor_internal;
		}
			
		
		/**
		 * A callback function that is set by a macro command for when
		 * this command completes successfully
		 * @param value The callback function
		 */		
		internal function set onCommandComplete(value:Function):void  {
			_onCommandComplete = value;
		}
		
		/**
		 * A callback function that is set by a macro command for when
		 * this command fails
		 * @param value The callback function
		 */		
		internal function set onCommandIncomplete(value:Function):void  {
			_onCommandIncomplete = value;
		}
		
		public function AsyncCommand():void {
			super();
		}
		
		/**
		 * When we start to execute the command 
		 */		
		override public function execute():void {
			super.execute();
			
			// detain this in memory so that we don't lose it in GC 
			commandMap.detain(this); 
		}
		
		/**
		 * When this function completes successfully, call this function 
		 * 
		 */		
		protected function commandComplete():void {
			// If we aren't inside of a batch, don't even worry about calling 
			// this function
			if(_onCommandComplete != null) {
				_onCommandComplete(subcommandDescriptor_internal);
			}
			cleanup();
		}
		
		/**
		 * When this function fails, call this function 
		 * 
		 */		
		protected function commandIncomplete():void {
			// If we aren't inside of a batch, don't even worry about calling 
			// this function
			if(_onCommandIncomplete != null) {
				_onCommandIncomplete(subcommandDescriptor_internal);
			}
			cleanup();
		}
		
		/**
		 * Cleans up and releases this command from the command map 
		 */		
		private function cleanup():void {
			commandMap.release(this);
		}
	}
}