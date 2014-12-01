package com.funkypanda.mixpanelane.events
{
import flash.events.Event;

/**
 * Dispatched if its not possible to register push notifications, e.g.
 * the app has a wrong certificate.
 */
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
