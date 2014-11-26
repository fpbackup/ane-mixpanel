package com.funkypanda.mixpanelane.events
{
import flash.events.Event;

public class MixPanelTrackErrorEvent extends Event
{
    public static const TYPE : String = "TRACK_ERROR";

    private var _message : String;

    public function MixPanelTrackErrorEvent(msg : String)
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
