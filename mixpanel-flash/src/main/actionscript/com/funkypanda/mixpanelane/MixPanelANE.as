package com.funkypanda.mixpanelane
{

    import com.funkypanda.mixpanelane.events.MixPanelANEDebugEvent;
import com.funkypanda.mixpanelane.events.MixPanelInitErrorEvent;
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

        public function initWithToken(mixPaneltoken : String) : void
        {
            if (mixPaneltoken == null)
            {
                dispatchEvent(new MixPanelInitErrorEvent("input parameters cannot be null"));
                return;
            }
            _extContext.call("initWithToken", mixPaneltoken);
        }

        /** properties must hold String key value pairs */
        public function track(eventName : String, properties : Object) : void
        {
            if (eventName == null || properties == null)
            {
                dispatchEvent(new MixPanelTrackErrorEvent("input parameters cannot be null"));
                return;
            }
            _extContext.call("track", eventName, JSON.stringify(properties)+";[454cvSZAR 55,./");
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
                // replies
                case MixPanelTrackErrorEvent.TYPE:
                    dispatchEvent(new MixPanelTrackErrorEvent(event.level));
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
