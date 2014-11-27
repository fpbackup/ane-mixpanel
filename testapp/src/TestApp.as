package
{

    import com.funkypanda.mixpanelane.MixPanelANE;
    import com.funkypanda.mixpanelane.events.MixPanelANEDebugEvent;
import com.funkypanda.mixpanelane.events.MixPanelTrackErrorEvent;

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
            service = MixPanelANE.service;
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            // debug - can be fired anytime
            service.addEventListener(MixPanelANEDebugEvent.DEBUG, function (evt : MixPanelANEDebugEvent) : void
            {
                log(evt.type + " " + evt.message);
            });
            service.addEventListener(MixPanelTrackErrorEvent.TYPE, function (evt : MixPanelTrackErrorEvent) : void
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

            var button : Button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.initWithToken("bc8c04d6fcbffac4cef575d830205777");
            });
            button.label = "init";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                service.track("sample event", {
                    prop1 : "testVal for prop1",
                    prop2 : true,
                    prop3 : ["arr1", "arr2", {embedded:"embedded object"}],
                    prop4 : Math.random()});
            });
            button.label = "track";
            button.validate();
            container.addChild(button);

            logTF = new ScrollText();
            logTF.height = stage.stageHeight - TOP;
            logTF.width = stage.stageWidth;
            logTF.y = TOP;
            logTF.textFormat = new TextFormat(null, 22, 0xdedede);
            addChild(logTF);

            log("Testing application for the MixPanel ANE.");
        }

        private function log(str : String) : void
        {
            logTF.text += str + "\n";
            trace(str);
        }

    }
}
