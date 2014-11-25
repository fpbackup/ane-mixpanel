package com.funkypanda.mixpanelane.events
{
    import flash.events.Event;

    public class MixPanelANEDebugEvent extends Event
    {

        public static const DEBUG : String = "DEBUG";

        public function MixPanelANEDebugEvent(data : String)
        {
            super(DEBUG);
            _message = data;
        }

        private var _message : String;
        public function get message() : String
        {
            return _message;
        }

    }
}
