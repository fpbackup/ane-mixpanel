package com.funkypanda.mixpanelane.events
{
import flash.events.Event;

public class MixPanelRegisterPushNotificationSuccessEvent extends Event
{
    public static const TYPE : String = "REMOTE_NOTIFICATIONS_REGISTER_SUCCESS";

    private var _token : String;

    public function MixPanelRegisterPushNotificationSuccessEvent(notificationToken : String)
    {
        super(TYPE);
        _token = notificationToken;
    }

    public function get token() : String
    {
        return _token;
    }
}
}
