package com.funkypanda.mixpanelane
{

import com.funkypanda.mixpanelane.events.MixPanelANEDebugEvent;
import com.funkypanda.mixpanelane.events.MixPanelInitErrorEvent;
import com.funkypanda.mixpanelane.events.MixPanelRegisterPushNotificationErrorEvent;
import com.funkypanda.mixpanelane.events.MixPanelRegisterPushNotificationSuccessEvent;
import com.funkypanda.mixpanelane.events.MixPanelTrackErrorEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.system.Capabilities;

    public class MixPanelANE extends EventDispatcher
    {

        public static const EXT_CONTEXT_ID : String = "com.funkypandagame.mixpanel";

        private static var _instance : MixPanelANE;
        private static var _extContext : ExtensionContext;

        public static function get service() : MixPanelANE
        {
            if (_instance == null)
            {
                _instance = new MixPanelANE();
            }
            return _instance;
        }

        public function MixPanelANE()
        {
            if (_instance == null)
            {
                try
                {
                    _extContext = ExtensionContext.createExtensionContext(EXT_CONTEXT_ID, null);
                    _extContext.addEventListener(StatusEvent.STATUS, extension_statusHandler);
                }
                catch (e : Error)
                {
                    throw new Error("The native extension context could not be created " + e);
                }
                return;
            }
            throw new Error("The singleton has already been created.");
        }

        /*
         * You must call this before making any other call.
         */
        public function initWithToken(mixPaneltoken : String) : void
        {
            if (mixPaneltoken == null)
            {
                dispatchEvent(new MixPanelInitErrorEvent("input parameters cannot be null"));
                return;
            }
            _extContext.call("initWithToken", mixPaneltoken);
        }

        /** properties must hold key value pairs where the values can be Strings, numeric types, and Boolean.
         *  Everything else will get converted to a String. For example:
         *  track("some event", {
         *       prop1 : "test value for prop1",
         *       prop2 : true,
         *       prop3 : 12345});
         *
         *  eventName and properties can not be null.
         */
        public function track(eventName : String, properties : Object) : void
        {
            if (eventName == null || properties == null)
            {
                dispatchEvent(new MixPanelTrackErrorEvent("input parameters cannot be null"));
                return;
            }
            _extContext.call("track", eventName, JSON.stringify(properties));
        }

        /** This causes the "Do you want to receive push notifications?" popup to appear. If the user has
         *  already answered it has not effect.
         *  Note for developers: iOS is designed to only ask permission for push once a day per application, this
         *  persists between reinstalls. To test it again, do thew following:
         *
         *  1. Delete your app from the device.
         *  2. Turn the device off completely and turn it back on.
         *  3. Go to Settings > General > Date & Time and set the date ahead a day or more.
         *  4. Turn the device off completely again and turn it back on.
         */
        public function registerForRemoteNotifications() : void
        {
            _extContext.call("registerForRemoteNotifications");
        }

        /**
         * The Mixpanel library will assign a default unique identifier (we call it a "distinct ID") to each unique user
         * who installs your application. This distinct ID is saved to device storage so that it will persist across sessions.
         *
         * If you choose, you can assign your own user IDs. This is particularly useful if a user is using your app on
         * multiple platforms (both web and mobile, for example). To assign your own distinct_ids, you can use identify.
         *
         * You should call this on every app startup
         */
        public function identify(userID : String) : void
        {
            _extContext.call("identify", userID);
        }

        /**
         * In situations where you want to link the two IDs (in practice, this really just means when the user signs up)
         * you should use createAlias:, which sends an update to our server linking the current ID with a new ID.
         *
         * You should call this on the first startup
         */
        public function createAlias(userID : String) : void
        {
            _extContext.call("createAlias", userID);
        }
        //////////////////////////////////////////////////////////////////////////////////////
        // NATIVE LIBRARY RESPONSE HANDLER
        //////////////////////////////////////////////////////////////////////////////////////

        private function extension_statusHandler(event : StatusEvent) : void
        {
            switch (event.code)
            {
                case MixPanelANEDebugEvent.DEBUG:
                    dispatchEvent(new MixPanelANEDebugEvent(event.level));
                    break;
                case MixPanelTrackErrorEvent.TYPE:
                    dispatchEvent(new MixPanelTrackErrorEvent(event.level));
                    break;
                case MixPanelRegisterPushNotificationSuccessEvent.TYPE:
                    dispatchEvent(new MixPanelRegisterPushNotificationSuccessEvent(event.level));
                    break;
                case MixPanelRegisterPushNotificationErrorEvent.TYPE:
                    dispatchEvent(new MixPanelRegisterPushNotificationErrorEvent(event.level));
                    break;
                default:
                    dispatchEvent(new MixPanelANEDebugEvent("Unknown event type received from the ANE. Data: " + event.level));
                    break;
            }
        }

        //////////////////////////////////////////////////////////////////////////////////////
        // HELPERS
        //////////////////////////////////////////////////////////////////////////////////////

        private static function get isAndroid() : Boolean
        {
            return (Capabilities.manufacturer.indexOf("Android") > -1);
        }

        private static function get isiOS() : Boolean
        {
            return (Capabilities.manufacturer.indexOf("iOS") > -1);
        }

    }
}
