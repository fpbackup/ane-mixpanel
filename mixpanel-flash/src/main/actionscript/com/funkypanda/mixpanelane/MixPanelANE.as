package com.funkypanda.mixpanelane
{

    import com.funkypanda.mixpanelane.events.MixPanelANEDebugEvent;

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

        /** Usage:
         * MixPanelANE.service.addEventListener(..); // The app dispatches events from the "events" package.
         * MixPanelANE.service.[command you want to execute];
         */
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

        /** Get the detailed product info from the store.
         *  Params:
         *  products: An Array of String product IDs
         *  Events dispatched as a reply:
         *  GetProductInfoSuccessEvent, GetProductInfoErrorEvent
         */
        public function getProductInfo(products : Array) : void
        {
            _extContext.call("getProductInfo", products);
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
                // ...
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
