//var memo="{\"hint\":\"定制內容信息，请勿修改！\",\"print\":{\"bucket\":\"ideadwork-dev\",\"key\":\"design/1E74885A-4CDB-4343-9545-472CA747401E/print.png\"},\"preview\":{\"bucket\":\"ideadwork-dev\",\"key\":\"design/1E74885A-4CDB-4343-9545-472CA747401E/preview.png\"}}";

var addExtention=function(){
    try{
        var designInfo=JSON.parse(memo);
        var memoXpath='//*[contains(@class,\"memo\")]//input[@type=\"text\"]';
        var memoInputElement = document.evaluate(memoXpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        memoInputElement.value=memo.replace(/"/g, '&quot;');
        //trigger change event
        var evt = document.createEvent("HTMLEvents");
        evt.initEvent("change", false, true);
        memoInputElement.dispatchEvent(evt);
        
        //set readonly
        document.evaluate(memoXpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.readOnly=true;
        
    }catch(error){
        console.log('add memo failed. '+error)
    }
    try{
        // add print and privew image on order confirm page
        var itemInfoXpath='//*[contains(@class,\"itemInfo\")]';
        var itemInfoElement=document.evaluate(itemInfoXpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
        
        // construct print and privew image section
        var designDiv = document.createElement('div');
        var designDivInnerHTMLT='<img src=\"http://imgx.sinacloud.net/'+designInfo.print.bucket+'/c_thumb,w_200/'+designInfo.print.key+'\" style="max-width:48%;padding: 1px 1px 1px 1px;"/>';
        designDivInnerHTMLT+='<img src=\"http://imgx.sinacloud.net/'+designInfo.preview.bucket+'/c_thumb,w_200/'+designInfo.preview.key+'\" style="max-width:48%;padding: 1px 1px 1px 1px;"/>';
        designDiv.innerHTML=designDivInnerHTMLT;
        if(itemInfoElement.nextSibling){
            itemInfoElement.parentElement.insertBefore(designDiv,itemInfoElement.nextSibling);
        }else{
            itemInfoElement.parentElement.appendChild(designDiv);
        }
    }catch(error){
        console.log('add print and preview error. '+error)
    }
}


// check if order page

var indexOfKeyword = window.location.href.indexOf("h5.m.taobao.com/awp/base/order.htm");
if (indexOfKeyword>0 & indexOfKeyword<10){
    var checkExist = setInterval(function() {
                                 var memoXpath='//*[contains(@class,\"memo\")]//input[@type=\"text\"]';
                                 var memoInputElement = document.evaluate(memoXpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
                                 if (memoInputElement) {
                                 console.log("Exists!");
                                 addExtention();
                                 clearInterval(checkExist);
                                 }
                                 }, 100);
}