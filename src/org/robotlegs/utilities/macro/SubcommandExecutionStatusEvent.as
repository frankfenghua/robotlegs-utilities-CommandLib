package org.robotlegs.utilities.macro
{
	import flash.events.Event;
	
	public class SubcommandExecutionStatusEvent extends Event
	{
		public static const SUBCOMMAND_WAITING_FOR_EXECUTION:String = "subcommandWaitingForExecution";
		public static const SUBCOMMAND_STARTED:String = "subcommandStarted";
		public static const SUBCOMMAND_COMPLETED:String = "subcommandCompleted";
		public static const SUBCOMMAND_FAILED:String = "subcommandFailed";
		
		public var subcommandDescriptor:SubcommandDescriptor;
		
		public function SubcommandExecutionStatusEvent(type:String, subcommandDescriptor:SubcommandDescriptor, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.subcommandDescriptor = subcommandDescriptor;
			super(type, bubbles, cancelable);
		}
		
		// Override the inherited clone() method.
		override public function clone():Event {
			return new SubcommandExecutionStatusEvent(type, subcommandDescriptor, bubbles, cancelable);
		}
	}
}