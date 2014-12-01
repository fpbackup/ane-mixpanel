package com.funkypanda.mixpanelane.events
{
import flash.events.Event;

public class MixPanelRegisterPushNotificationErrorEvent extends Event
{
    public static const TYPE : String = "REMOTE_NOTIFICATIONS_REGISTER_ERROR";

    private var _message : String;

    public function MixPanelRegisterPushNotificationErrorEvent(msg : String)
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
