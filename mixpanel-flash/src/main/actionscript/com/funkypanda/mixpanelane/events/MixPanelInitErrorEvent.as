package com.funkypanda.mixpanelane.events
{
import flash.events.Event;

public class MixPanelInitErrorEvent extends Event
{
    public static const TYPE : String = "INIT_ERROR";

    private var _message : String;

    public function MixPanelInitErrorEvent(msg : String)
    {
        super(TYPE);
        _message = msg;
    }

    public function get message() : String
    {
        return _message;
    }
}
}
