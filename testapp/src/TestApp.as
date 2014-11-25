package
{

    import feathers.controls.Button;
    import feathers.controls.ScrollContainer;
    import feathers.controls.ScrollText;
    import feathers.layout.TiledColumnsLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import flash.events.UncaughtErrorEvent;

    import flash.text.TextFormat;

    import starling.core.Starling;

    import starling.display.Sprite;
    import starling.events.Event;

    public class TestApp extends Sprite
    {
        // taken from rinoa client
        public static const GOOGLE_PLAY_PUBLIC_KEY : String = "TODO GET KEY";

        private var service : MixPanelANE;

        private var logTF : ScrollText;
        private static const TOP : uint = 445;
        private const container: ScrollContainer = new ScrollContainer();


        public function TestApp()
        {
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            // debug - can be fired anytime
            service.addEventListener(PurchaseDebugEvent.DEBUG, function (evt : PurchaseDebugEvent) : void
            {
                log(evt.type + " " + evt.message);
            });
        }

        protected function addedToStageHandler(event : Event) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            stage.addEventListener(Event.RESIZE, function(evt : Event) : void
            {
                logTF.height = stage.stageHeight - TOP;
                logTF.width = stage.stageWidth;
                container.width = stage.stageWidth;
            });


            Starling.current.nativeStage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,
            function (e:UncaughtErrorEvent):void
            {
                log("UNCAUGHT ERROR " + e.toString());
            });

            new MetalWorksMobileTheme();

            var layout : TiledColumnsLayout = new TiledColumnsLayout();
            layout.useSquareTiles = false;
            container.layout = layout;
            container.width = stage.stageWidth;
            container.height = TOP;
            addChild(container);
/*
            var button : Button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.setAndroidKey(GOOGLE_PLAY_PUBLIC_KEY);
            });
            button.label = "setAndroidKey";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["at_gp_pro_5_199_a", "at_gp_reg_3_1499", "at_gp_pro_up_5_199"]);
            });
            button.label = "getProductsInfo android";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["at_gp_sweep_999_1800k", "BAD_ID", "at_gp_reg_2_499"]);
            });
            button.label = "getProductsInfo android 1 wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["general_150000_299_ipad", "general_900000_899_ipad", "general_2700000_1799_ipad"]);
            });
            button.label = "getProductsInfo iOS";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["general_150000_299_ipad", "BAD_ID", "general_2700000_1799_ipad"]);
            });
            button.label = "getProductsInfo iOS 1 wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getProductInfo(["wrong_id", "BAD_ID"]);
            });
            button.label = "getProductsInfo all wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getCanMakeAPurchase();
            });
            button.label = "getCanMakeAPurchase";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.makePurchase("general_150000_299_ipad");
            });
            button.label = "makePurchase good ID iOS";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.makePurchase("at_gp_reg_2_499");
            });
            button.label = "makePurchase good ID android";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.consumePurchase("bad_ID");
            });
            button.label = "consumePurchase wrong ID";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.getPurchasedItems();
            });
            button.label = "getPurchasedItems";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                if (unconsumedPurchase != null)
                {
                    service.consumePurchase(unconsumedPurchase.transactionReceipt);
                }
                else
                {
                    log("No unconsumed purchase. Either call makePurchase or getPurchasedItems");
                }
            });
            button.label = "consume 1 pending";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                logTF.text = "";
            });
            button.label = "CLEAR LOG";
            button.validate();
            container.addChild(button);
*/
            logTF = new ScrollText();
            logTF.height = stage.stageHeight - TOP;
            logTF.width = stage.stageWidth;
            logTF.y = TOP;
            logTF.textFormat = new TextFormat(null, 22, 0xdedede);
            addChild(logTF);

            log("Testing application for the mixpanel ANE.");
        }

        private function log(str : String) : void
        {
            logTF.text += str + "\n";
            trace(str);
        }

    }
}
