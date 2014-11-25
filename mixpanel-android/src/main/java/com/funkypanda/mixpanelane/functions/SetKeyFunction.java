package com.funkypanda.mixpanelane.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.mixpanelane.ANEUtils;
import com.funkypanda.mixpanelane.Extension;

public class SetKeyFunction implements FREFunction
{
    @Override
    public FREObject call(FREContext context, FREObject[] args)
    {
        Extension.base64EncodedKey = ANEUtils.getStringFromFREObject(args[0]);
        return null;
    }

}