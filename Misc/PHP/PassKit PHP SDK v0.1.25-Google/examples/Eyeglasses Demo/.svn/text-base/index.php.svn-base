<?php

/**
 * Index.php
 * 
 * Simple landing page to demonstarte use of the PassKit API to create a
 * personalised pass that includes a user provided thumbnail image.
 * 
 * @author PassKit, Inc.
 * @copyright PassKit, Inc. http://passkit.com
 * @license http://www.opensource.org/licenses/gpl-license.php
 * @package PassKitSDK
 */


// Set some variables
$apiKey = ""; // Add your PassKit API Key
$apiSecret = ""; // Add your PassKit API Secret
// You can add the tempalte for this pass to you PassKit account at https://create.passkit.com/loader/?t=FmmoS0hpZ17T9hIGG16G&c=1
$template_name = "Spectacle-Prescription-Card";
$pass_name = "PassKit Demo Pass";
$pass_description = "This pass demonstrates how the PassKit API can be used to provide passes for small and independent businesses and professional practices.</p><p>If you would like the source code for this page, please email us at <a href='mailto:support@passkit.com' title='PassKit Support'>support@passkit.com</a>.";
$pass_image = "https://passkit.s3.amazonaws.com/images/3pfT7duf0ARu6erMac0y4ri2x.png";
$pass_error = false; // this variabale will hold error message if there is an issue

// Import the PassKit class
require_once realpath(dirname(__FILE__)  . '/../../SDK/class-PassKit.php');

// Create a new PassKit Object
$pk = new PassKit($apiKey, $apiSecret);

// Test API conntection - no need to do this in live environment;
if (!$pk->pk_test_connection())
	die("API Connection Error - check API Keys");

$template = $pk->get_dynamic_template_fields($template_name);

// Set the form fields
$formFields = array(
		'Name' =>	array(	 // Must correspond exactly to the template Item Name
			  	'Field_label' => 'Name', // Label to be displayed above the field name
				'Field_type'  => 'data', // Valid values are 'label', 'data', 'backdata', 'image'
				'Field_content' => 'text' // Valid values are 'text', 'numeric', 'date', 'datetime'
		),
		'Right' =>	array (
			  	'Field_label' => 'Prescription - Right Eye',
				'Field_type'  => 'data',
				'Field_content' => 'text'
		),
		'Left' =>	array (
				'Field_label' => 'Prescription - Left Eye',
				'Field_type'  => 'data',
				'Field_content' => 'text'
		),
		'Date' =>	array (
				'Field_label' => 'Date of last eye exam',
				'Field_type'  => 'data',
				'Field_content' => 'date'
		),
		'Expire' =>	array (
				'Field_label' => 'Prescription expiry date',
				'Field_type'  => 'data',
				'Field_content' => 'date'
		),
		'Optician' => array (
				'Field_label' => 'Prescribing Optician',
				'Field_type'  => 'backdata',
				'Field_content' => 'text'
		),
		'thumbnailImage' => array(  // For images use 'thumbnailImage, stripImage, logoImage, footerImage, backgroundImage or iconImage
				'Field_label' => 'Upload your photo',
				'Field_type'  => 'image',
				'Field_content' => 'thumbnail' // For images use 'thumbnail', 'logo', 'strip', 'footer', 'background' or 'icon'
		)
		);

// Check if this is a form submission and if so process form data
if (!empty($_POST) || !empty($_FILES)) {

	// Check if images are present and if so upload and obtain an image ID
	$imageFields = array ('thumbnailImage', 'stripImage', 'logoImage', 'footerImage', 'backgroundImage', 'iconImage');

	// Check if images are present and if so upload and obtain an image ID
	foreach($imageFields as $imageType) {
		if (isset($_FILES[$imageType]) && !($_FILES[$imageType]['error'] > 0) && isset($formFields[$imageType]))
			{
				$imageID = $pk->pk_image_upload($formFields[$imageType]['Field_content'], $_FILES[$imageType]["tmp_name"], $_FILES[$imageType]["type"]);

				// if an imageID is returned, set the from fiels value
				if ($imageID)
					$formFields[$imageType]['value'] = $imageID;
				else
					$pass_error = true;
			}
	}

	// Add values to each field and construct an array containing the pass data
	$passData = array();

	foreach($formFields as $field => $fieldMeta) {
		if (isset($_POST[$field]) && strlen($_POST[$field]))
			$formFields[$field]['value'] = $_POST[$field];
		elseif (isset($POST[$field . '_label']) && strlen($_POST[$field . '_label'])) {
			$formFields[$field . '_label'] = array('value' => $_POST[$field . '_label']);
		}

		// If no value is provied, then PassKit will use the default value or leave blank (or use today for date items)
		if (isset($formFields[$field]['value']))
			$passData[$field] = $formFields[$field]['value'];
		elseif(isset($formFields[$field . '_label']['value']))
			$passData[$field . '_label'] = $formFields[$field . '_label']['value'];
	}

	// Capture and submit recovery email address
	if (isset($_POST['recoveryEmail']) && $_POST['recoveryEmail'])
		$passData['recoveryEmail'] = $_POST['recoveryEmail'];

	// Capture and submit install location data or note that location permission was not given
	if (isset($_POST['iLat']) && $_POST['iLat']) {
		$passData['installLatitude'] = $_POST['iLat'];
		$passData['installLongitude'] = $_POST['iLng'];
	} elseif (isset($_POST['iLoc']) && $_POST['iLoc']) {
		$passData['locationDeclined'] = $_POST['iLoc'];
	}

	// If no errors so far, create a new pass and retrieve the URL - we let the PassKit API handle data validation
	if (!$pass_error)
		$newPass = $pk->pk_issue_pass($template_name, $passData, true);

	// If error, display error message. In practice, you may want to more gracefully handle errors
	if (isset($pk->pk_error_result->error))
		$pass_error = isset($pk->pk_error_result->m) ? $pk->pk_error_result->m : $pk->pk_error_result->error;
}


// Variables for the various form elements
$input_template = '<div data-role="fieldcontain" style="margin-top:-10px">' .
		'<label for="%1$s">%2$s<em> *</em></label>' .
		'<input id="%1$s" class="required%4$s" name="%1$s" type="text" value="%3$s"/>' .
		'</div>';

$textarea_template = '<div data-role="fieldcontain" style="margin-top:-10px">' .
		'<label for="%1$s">%2$s<em> *</em></label>' .
		'<textarea id="%1$s" class="required%4$s" name="%1$s">%3$s</textarea>' .
		'</div>';

$image_template = '<div data-role="fieldcontain" style="margin-top:-10px">' .
		'<label for="%1$s">%2$s<em> *</em></label>' .
		'<input type="file" id="%1$s" name="%1$s" />' .
		'</div>';

?>

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no">
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="apple-mobile-web-app-status-bar-style" content="black" />
	<title><?php echo $pass_name; ?></title>
	<link rel="stylesheet" href="https://ajax.aspnetcdn.com/ajax/jquery.mobile/1.1.1/jquery.mobile-1.1.1.min.css" />
	<link href="https://d321ofrgjjwiwz.cloudfront.net/samples/iphone.css" rel="stylesheet" type="text/css"/>
	<script src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.8.0.min.js"></script>
	<script src="https://ajax.aspnetcdn.com/ajax/jquery.mobile/1.1.1/jquery.mobile-1.1.1.min.js"></script>
	<script type="text/javascript">
		/*!  jQuery MobiScroll @v 2.0 @l MIT | mobiscroll.com @modified passk.it */
		(function(f){function B(M,Y){var N=this,X=M,M=f(X),Z,S=f.extend({},k),T,Q,L={},ab={},P=M.is("input, textarea"),K=false;function O(){var ac=document.body,ad=document.documentElement;return Math.max(ac.scrollHeight,ac.offsetHeight,ad.clientHeight,ad.scrollHeight,ad.offsetHeight)}function V(ac){u=f("li.dw-v",ac).eq(0).index();x=f("li.dw-v",ac).eq(-1).index();z=S.height;b=N}function h(ac){var ad=S.headerText;return ad?(typeof(ad)=="function"?ad.call(X,ac):ad.replace(/{value}/i,ac)):""}function U(){N.temp=((P&&N.val!==null&&N.val!=M.val())||N.values===null)?S.parseValue(M.val()?M.val():"",N):N.values.slice(0);N.setValue(true)}function R(af,ag,ad,ae,ac){S.validate.call(X,Q,ad);f(".dww ul",Q).each(function(al){var ak=f(this),ai=f('li[data-val="'+N.temp[al]+'"]',ak),ah=ai.index(),aj=J(ai,ah,al,ac),am=al==ad||ad===undefined;if(ah!=aj||am){N.scroll(f(this),aj,am?af:0,ag,al)}});N.change(ae)}function J(ac,aj,ag,af){if(!ac.hasClass("dw-v")){var ae=ac,ad=ac,ai=0,ah=0;while(ae.prev().length&&!ae.hasClass("dw-v")){ae=ae.prev();ai++}while(ad.next().length&&!ad.hasClass("dw-v")){ad=ad.next();ah++}if(((ah<ai&&ah&&!af==1)||!ai||!ae.hasClass("dw-v")||af==1)&&ad.hasClass("dw-v")){ac=ad;aj=aj+ah}else{ac=ae;aj=aj-ai}N.temp[ag]=ac.data("val")}return aj}function aa(){var ak=0,aj=0,ae=f(window).width(),ac=f(window).height(),ai=f(window).scrollTop(),ad=f(".dwo",Q),ag=f(".dw",Q),ah,af;f(".dwc",Q).each(function(){ah=f(this).outerWidth(true);ak+=ah;aj=(ah>aj)?ah:aj});ah=ak>ae?aj:ak;ag.width(ah);ah=ag.outerWidth();af=ag.outerHeight();ag.css({left:(ae-ah)/2,top:ai+(ac-af)/2});ad.height(0).height(O())}function W(ac){var ad=+ac.data("pos"),ae=ad+1;a(ac,ae>x?u:ae,1)}function I(ac){var ad=+ac.data("pos"),ae=ad-1;a(ac,ae<u?x:ae,2)}N.enable=function(){S.disabled=false;if(P){M.prop("disabled",false)}};N.disable=function(){S.disabled=true;if(P){M.prop("disabled",true)}};N.scroll=function(af,ai,ah,aj,ac){var ae=(T-ai)*S.height;af.attr("style",(ah?(w+"-transition:all "+ah.toFixed(1)+"s ease-out;"):"")+(m?(w+"-transform:translate3d(0,"+ae+"px,0);"):("top:"+ae+"px;")));function ag(al,ak,an,am){return an*Math.sin(al/am*(Math.PI/2))+ak}if(ah){var ad=0;clearInterval(L[ac]);L[ac]=setInterval(function(){ad+=0.1;af.data("pos",Math.round(ag(ad,aj,ai-aj,ah)));if(ad>=ah){clearInterval(L[ac]);af.data("pos",ai)}},100);clearTimeout(ab[ac]);ab[ac]=setTimeout(function(){if(S.mode=="mixed"&&!af.hasClass("dwa")){af.closest(".dwwl").find(".dwwb").fadeIn("fast")}},ah*1000)}else{af.data("pos",ai)}};N.setValue=function(af,ae,ad){var ac=S.formatResult(N.temp);N.val=ac;N.values=N.temp.slice(0);if(K&&af){R(ad)}if(ae&&P){M.val(ac).trigger("change")}};N.validate=function(ae,af,ad,ac){R(ae,af,ad,true,ac)};N.change=function(ad){var ac=S.formatResult(N.temp);if(S.display=="inline"){N.setValue(false,ad)}else{f(".dwv",Q).html(h(ac))}if(ad){S.onChange.call(X,ac,N)}};N.hide=function(){if(S.onClose.call(X,N.val,N)===false){return false}f(".dwtd").prop("disabled",false).removeClass("dwtd");M.blur();if(Q){Q.remove()}K=false;f(window).unbind(".dw")};N.show=function(){if(S.disabled||K){return false}var af=S.height,ac=S.rows*af;U();var ah='<div class="'+S.theme+'">'+(S.display=="inline"?'<div class="dw dwbg dwi"><div class="dwwr">':'<div class="dwo"></div><div class="dw dwbg"><div class="dwwr">'+(S.headerText?'<div class="dwv"></div>':""));for(var ag=0;ag<S.wheels.length;ag++){ah+='<div class="dwc'+(S.mode!="scroller"?" dwpm":" dwsc")+(S.showLabel?"":" dwhl")+'"><div class="dwwc dwrc"><table cellpadding="0" cellspacing="0"><tr>';for(var ae in S.wheels[ag]){ah+='<td><div class="dwwl dwrc">'+(S.mode!="scroller"?'<div class="dwwb dwwbp" style="height:'+af+"px;line-height:"+af+'px;"><span>+</span></div><div class="dwwb dwwbm" style="height:'+af+"px;line-height:"+af+'px;"><span>&ndash;</span></div>':"")+'<div class="dwl">'+ae+'</div><div class="dww dwrc" style="height:'+ac+"px;min-width:"+S.width+'px;"><ul>';for(var ad in S.wheels[ag][ae]){ah+='<li class="dw-v" data-val="'+ad+'" style="height:'+af+"px;line-height:"+af+'px;">'+S.wheels[ag][ae][ad]+"</li>"}ah+='</ul><div class="dwwo"></div></div><div class="dwwol"></div></div></td>'}ah+="</tr></table></div></div>"}ah+=(S.display!="inline"?'<div class="dwbc"><span class="dwbw dwb-s"><a href="#" class="dwb">'+S.setText+'</a></span><span class="dwbw dwb-c"><a href="#" class="dwb">'+S.cancelText+"</a></span></div>":'<div class="dwcc"></div>')+"</div></div></div>";Q=f(ah);R();S.display!="inline"?Q.appendTo("body"):M.is("div")?M.html(Q):Q.insertAfter(M);K=true;Z.init(Q,N);if(S.display!="inline"){f(".dwb-s a",Q).click(function(){N.setValue(false,true);N.hide();S.onSelect.call(X,N.val,N);return false});f(".dwb-c a",Q).click(function(){N.hide();S.onCancel.call(X,N.val,N);return false});f("input,select").each(function(){if(!f(this).prop("disabled")){f(this).addClass("dwtd")}});f("input,select").prop("disabled",true);aa();f(window).bind("resize.dw",aa)}Q.delegate(".dwwl","DOMMouseScroll mousewheel",function(ak){if(!S.readonly){ak.preventDefault();ak=ak.originalEvent;var am=ak.wheelDelta?(ak.wheelDelta/120):(ak.detail?(-ak.detail/3):0),ai=f("ul",this),aj=+ai.data("pos"),al=Math.round(aj-am);V(ai);a(ai,al,am<0?1:2)}}).delegate(".dwb, .dwwb",v,function(ai){f(this).addClass("dwb-a")}).delegate(".dwwb",v,function(aj){if(!S.readonly){aj.preventDefault();aj.stopPropagation();var ai=f(this).closest(".dwwl").find("ul");func=f(this).hasClass("dwwbp")?W:I;V(ai);clearInterval(n);n=setInterval(function(){func(ai)},S.delay);func(ai)}}).delegate(".dwwl",v,function(ai){if(!r&&S.mode!="clickpick"&&!S.readonly){ai.preventDefault();r=true;G=f("ul",this).addClass("dwa");if(S.mode=="mixed"){f(".dwwb",this).fadeOut("fast")}g=+G.data("pos");V(G);e=A(ai);p=new Date();s=e;N.scroll(G,g)}});S.onShow.call(X,Q,N)};N.init=function(ac){Z=f.extend({defaults:{},init:j},f.scroller.themes[ac.theme?ac.theme:S.theme]);f.extend(S,Z.defaults,Y,ac);N.settings=S;T=Math.floor(S.rows/2);var ad=f.scroller.presets[S.preset];M.unbind(".dw");if(ad){var ae=ad.call(X,N);f.extend(S,ae,Y,ac);f.extend(C,ae.methods)}if(M.data("dwro")!==undefined){X.readOnly=o(M.data("dwro"))}if(K){N.hide()}if(S.display=="inline"){N.show()}else{U();if(P&&S.showOnFocus){M.data("dwro",X.readOnly);X.readOnly=true;M.bind("focus.dw",N.show)}}};N.values=null;N.val=null;N.temp=null;N.init(Y)}function H(I){for(var h in I){if(F[I[h]]!==undefined){return true}}return false}function c(){var h=["Webkit","Moz","O","ms"];for(var I in h){if(H([h[I]+"Transform"])){return"-"+h[I].toLowerCase()}}return""}function t(h){return l[h.id]}function A(h){return i?(h.originalEvent?h.originalEvent.changedTouches[0].pageY:h.changedTouches[0].pageY):h.pageY}function o(h){return(h===true||h=="true")}function a(K,M,I,L,N){var J=K.closest(".dwwr").find("ul").index(K);M=M>x?x:M;M=M<u?u:M;var h=f("li",K).eq(M);b.temp[J]=h.data("val");b.validate(L?(M==N?0.1:Math.abs((M-N)*0.1)):0,N,J,I)}var l={},n,j=function(){},z,u,x,b,E=new Date(),y=E.getTime(),r=false,G=null,e,s,p,d,g,F=document.createElement(F).style,m=H(["perspectiveProperty","WebkitPerspective","MozPerspective","OPerspective","msPerspective"])&&"webkitPerspective" in document.documentElement.style,w=c(),i=("ontouchstart" in window),v=i?"touchstart":"mousedown",D=i?"touchmove":"mousemove",q=i?"touchend":"mouseup",k={width:70,height:40,rows:3,delay:300,disabled:false,readonly:false,showOnFocus:true,showLabel:true,wheels:[],theme:"",headerText:"{value}",display:"modal",mode:"scroller",preset:"",setText:"Set",cancelText:"Cancel",onShow:j,onClose:j,onSelect:j,onCancel:j,onChange:j,formatResult:function(J){var h="";for(var I=0;I<J.length;I++){h+=(I>0?" ":"")+J[I]}return h},parseValue:function(O,N){var I=N.settings.wheels,O=O.split(" "),L=[],K=0;for(var M=0;M<I.length;M++){for(var h in I[M]){if(I[M][h][O[K]]!==undefined){L.push(O[K])}else{for(var J in I[M][h]){L.push(J);break}}K++}}return L},validate:j},C={init:function(h){if(h===undefined){h={}}return this.each(function(){if(!this.id){y+=1;this.id="scoller"+y}l[this.id]=new B(this,h)})},enable:function(){return this.each(function(){var h=t(this);if(h){h.enable()}})},disable:function(){return this.each(function(){var h=t(this);if(h){h.disable()}})},isDisabled:function(){var h=t(this[0]);if(h){return h.settings.disabled}},option:function(h,I){return this.each(function(){var J=t(this);if(J){var K={};if(typeof h==="object"){K=h}else{K[h]=I}J.init(K)}})},setValue:function(J,I,h){return this.each(function(){var K=t(this);if(K){K.temp=J;K.setValue(true,I,h)}})},getInst:function(){return t(this[0])},getValue:function(){var h=t(this[0]);if(h){return h.values}},show:function(){var h=t(this[0]);if(h){return h.show()}},hide:function(){return this.each(function(){var h=t(this);if(h){h.hide()}})},destroy:function(){return this.each(function(){var h=t(this);if(h){h.hide();f(this).unbind(".dw");delete l[this.id];if(f(this).is("input,textarea")){this.readOnly=o(f(this).data("dwro"))}}})}};f(document).bind(D,function(h){if(r){h.preventDefault();s=A(h);var I=g+(e-s)/z;I=I>(x+1)?(x+1):I;I=I<(u-1)?(u-1):I;b.scroll(G,I)}});f(document).bind(q,function(J){if(r){J.preventDefault();G.removeClass("dwa");var I=new Date()-p,L=g+(e-s)/z;L=L>(x+1)?(x+1):L;L=L<(u-1)?(u-1):L;if(I<300){var h=(s-e)/I;var K=(h*h)/(2*0.0006);if(s-e<0){K=-K}}else{var K=s-e}a(G,Math.round(g-K/z),0,true,Math.round(L));r=false;G=null}clearInterval(n);f(".dwb-a").removeClass("dwb-a")});f.fn.scroller=function(h){if(C[h]){return C[h].apply(this,Array.prototype.slice.call(arguments,1))}else{if(typeof h==="object"||!h){return C.init.apply(this,arguments)}else{f.error("Unknown method")}}};f.scroller={setDefaults:function(h){f.extend(k,h)},presets:{},themes:{}}})(jQuery);(function(c){var a=new Date(),d={dateFormat:"yy-mm-ddTHH:ii:ssZ",dateOrder:"Mddyy",timeWheels:"hhiiA",timeFormat:"",startYear:a.getFullYear()-10,endYear:a.getFullYear()+10,monthNames:["January","February","March","April","May","June","July","August","September","October","November","December"],monthNamesShort:["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],dayNames:["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],dayNamesShort:["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],timeZones:[{"-12":"-12:00","-11":"-11:00","-10":"-10:00","-9.5":"-09:30","-9":"-09:00","-8":"-08:00","-7":"-07:00","-6":"-06:00","-5":"-05:00","-4.5":"-04:30","-4":"-04:00","-3.5":"-03:30","-3":"-03:00","-2.5":"-02:30","-2":"-02:00","-1":"-01:00","Z":"+00:00","1":"+01:00","2":"+02:00","3":"+03:00","3.5":"+03:30","4":"+04:00","4.5":"+04:30","5":"+05:00","5.5":"+05:30","5.75":"+05:45","6":"+06:00","6.5":"+06:30","7":"+07:00","8":"+08:00","8.75":"+08:45","9":"+09:00","9.5":"+09:30","10":"+10:00","10.5":"+10:30","11":"+11:00","11.5":"+11:30","12":"+12:00","12.75":"+12:45","13":"+13:00","14":"+14:00"}],shortYearCutoff:"+10",monthText:"Month",dayText:"Day",yearText:"Year",hourText:"Hours",minuteText:"Minutes",secText:"Seconds",ampmText:"&nbsp;",stepHour:1,stepMinute:1,stepSecond:1,separator:" "},b=function(D){var G=c(this),C;if(G.is("input,textarea")){switch(G.attr("type")){case"date":C="yy-mm-dd";break;case"datetime":C="yy-mm-ddTHH:ii:ssZ";break;case"datetime-local":C="yy-mm-ddTHH:ii:ss";break;case"month":C="yy-mm";d.dateOrder="mmyy";break;case"time":C="HH:ii:ss";break}var W=G.attr("min"),y=G.attr("max");if(W){d.minDate=c.scroller.parseDate(C,W)}if(y){d.maxDate=c.scroller.parseDate(C,y)}}var K=c.extend({},d,D.settings),I=0,q=[],S=[],N={},T={y:"getFullYear",m:"getMonth",d:"getDate",h:V,i:J,s:l,ap:x,Z:getOffset},L=K.preset,U=K.dateOrder,B=K.timeWheels,n=U.match(/D/),A=B.match(/a/i),h=B.match(/h/),O=L=="datetime"?K.dateFormat+K.separator+K.timeFormat:L=="time"?K.timeFormat:K.dateFormat,e=new Date(),m=K.stepHour,j=K.stepMinute,g=K.stepSecond,E=K.minDate,r=K.maxDate;C=C?C:O;if(L.match(/date/i)){c.each(["y","m","d"],function(k,f){var k=U.search(new RegExp(f,"i"));if(k>-1){S.push({o:k,v:f})}});S.sort(function(i,f){return i.o>f.o?1:-1});c.each(S,function(k,f){N[f.v]=k});var H={};for(var P=0;P<3;P++){if(P==N.y){I++;H[K.yearText]={};var z=E?E.getFullYear():K.startYear,u=r?r.getFullYear():K.endYear;for(var R=z;R<=u;R++){H[K.yearText][R]=U.match(/yy/i)?R:(R+"").substr(2,2)}}else{if(P==N.m){I++;H[K.monthText]={};for(var R=0;R<12;R++){H[K.monthText][R]=U.match(/MM/)?K.monthNames[R]:U.match(/M/)?K.monthNamesShort[R]:U.match(/mm/)&&R<9?"0"+(R+1):R+1}}else{if(P==N.d){I++;H[K.dayText]={};for(var R=1;R<32;R++){H[K.dayText][R]=U.match(/dd/i)&&R<10?"0"+R:R}}}}}q.push(H)}if(L.match(/time/i)){var H={};if(B.match(/h/i)){N.h=I++;H[K.hourText]={};for(var R=0;R<(h?12:24);R+=m){H[K.hourText][R]=h&&R==0?12:B.match(/hh/i)&&R<10?"0"+R:R}}if(B.match(/i/)){N.i=I++;H[K.minuteText]={};for(var R=0;R<60;R+=j){H[K.minuteText][R]=B.match(/ii/)&&R<10?"0"+R:R}}if(B.match(/s/)){N.s=I++;H[K.secText]={};for(var R=0;R<60;R+=g){H[K.secText][R]=B.match(/ss/)&&R<10?"0"+R:R}}if(A){N.ap=I++;var M=B.match(/A/);H[K.ampmText]={0:M?"AM":"am",1:M?"PM":"pm"}}q.push(H)}function Q(o,f,k){if(N[f]!==undefined){return +o[N[f]]}if(k!==undefined){return k}return e[T[f]]?e[T[f]]():T[f](e)}function F(f,i){return Math.floor(f/i)*i}function V(i){var f=i.getHours();f=h&&f>=12?f-12:f;return F(f,m)}function J(f){return F(f.getMinutes(),j)}function l(f){return F(f.getSeconds(),g)}function x(f){return A&&f.getHours()>11?1:0}function v(i){var f=Q(i,"h",0);return new Date(Q(i,"y"),Q(i,"m"),Q(i,"d"),Q(i,"ap")?f+12:f,Q(i,"i",0),Q(i,"s",0))}function t(f,i){var k="00"+f;return k.substr(k.length-i)}D.setDate=function(p,o,k){for(var f in N){this.temp[N[f]]=p[T[f]]?p[T[f]]():T[f](p)}this.setValue(true,o,k)};D.getDate=function(f){return v(f)};return{wheels:q,headerText:function(f){return c.scroller.formatDate(O,v(D.temp),K)},formatResult:function(f){return c.scroller.formatDate(C,v(f),K)},parseValue:function(s){var p=new Date(),f=[];try{p=c.scroller.parseDate(C,s,K)}catch(o){}for(var k in N){f[N[k]]=p[T[k]]?p[T[k]]():T[k](p)}return f},validate:function(p,s){var k=D.temp,Y={m:0,d:1,h:0,i:0,s:0,ap:0},o={m:11,d:31,h:F(h?11:23,m),i:F(59,j),s:F(59,g),ap:1},f=(E||r)?["y","m","d","ap","h","i","s"]:((s==N.y||s==N.m||s===undefined)?["d"]:[]),X=true,Z=true;c.each(f,function(aj,af){if(N[af]!==undefined){var ae=Y[af],ai=o[af],ad=31,w=Q(k,af),al=c("ul",p).eq(N[af]),ah,aa;if(af=="d"){ah=Q(k,"y"),aa=Q(k,"m");ad=32-new Date(ah,aa,32).getDate();ai=ad;if(n){c("li",al).each(function(){var am=c(this),an=am.data("val"),i=new Date(ah,aa,an).getDay();am.html(U.replace(/[my]/gi,"").replace(/dd/,an<10?"0"+an:an).replace(/d/,an).replace(/DD/,K.dayNames[i]).replace(/D/,K.dayNamesShort[i]))})}}if(X&&E){ae=E[T[af]]?E[T[af]]():T[af](E)}if(Z&&r){ai=r[T[af]]?r[T[af]]():T[af](r)}if(af!="y"){var ac=c('li[data-val="'+ae+'"]',al).index(),ab=c('li[data-val="'+ai+'"]',al).index();c("li",al).removeClass("dw-v").slice(ac,ab+1).addClass("dw-v");if(af=="d"){c("li",al).removeClass("dw-h").slice(ad).addClass("dw-h")}if(w<ae){w=ae}if(w>ai){w=ai}}if(X){X=w==ae}if(Z){Z=w==ai}if(K.invalid&&af=="d"){var ak=[];if(K.invalid.dates){c.each(K.invalid.dates,function(an,am){if(am.getFullYear()==ah&&am.getMonth()==aa){ak.push(am.getDate()-1)}})}if(K.invalid.daysOfWeek){var ag=new Date(ah,aa,1).getDay();c.each(K.invalid.daysOfWeek,function(ao,am){for(var an=am-ag;an<ad;an+=7){if(an>=0){ak.push(an)}}})}if(K.invalid.daysOfMonth){c.each(K.invalid.daysOfMonth,function(an,am){am=(am+"").split("/");if(am[1]){if(am[0]-1==aa){ak.push(am[1]-1)}}else{ak.push(am[0]-1)}})}c.each(ak,function(an,am){c("li",al).eq(am).removeClass("dw-v")})}}})},methods:{getDate:function(f){var i=c(this).scroller("getInst");if(i){return i.getDate(f?i.temp:i.values)}},setDate:function(k,i,f){if(i==undefined){i=false}return this.each(function(){var o=c(this).scroller("getInst");if(o){o.setDate(k,i,f)}})}}}};c.scroller.presets.date=b;c.scroller.presets.datetime=b;c.scroller.presets.time=b;c.scroller.formatDate=function(p,f,g){if(!f){return null}var q=c.extend({},d,g),n=function(h){var i=0;while(l+1<p.length&&p.charAt(l+1)==h){i++;l++}return i},k=function(i,r,h){var s=""+r;if(n(i)){while(s.length<h){s="0"+s}}return s},j=function(h,t,r,i){return(n(h)?i[t]:r[t])},e="",o=false;for(var l=0;l<p.length;l++){if(o){if(p.charAt(l)=="'"&&!n("'")){o=false}else{e+=p.charAt(l)}}else{switch(p.charAt(l)){case"d":e+=k("d",f.getDate(),2);break;case"D":e+=j("D",f.getDay(),q.dayNamesShort,q.dayNames);break;case"o":e+=k("o",(f.getTime()-new Date(f.getFullYear(),0,0).getTime())/86400000,3);break;case"m":e+=k("m",f.getMonth()+1,2);break;case"M":e+=j("M",f.getMonth(),q.monthNamesShort,q.monthNames);break;case"y":e+=(n("y")?f.getFullYear():(f.getYear()%100<10?"0":"")+f.getYear()%100);break;case"h":var m=f.getHours();e+=k("h",(m>12?(m-12):(m==0?12:m)),2);break;case"H":e+=k("H",f.getHours(),2);break;case"i":e+=k("i",f.getMinutes(),2);break;case"s":e+=k("s",f.getSeconds(),2);break;case"a":e+=f.getHours()>11?"pm":"am";break;case"A":e+=f.getHours()>11?"PM":"AM";break;case"Z":e+=getOffset(f);break;case"'":if(n("'")){e+="'"}else{o=true}break;default:e+=p.charAt(l)}}}return e};c.scroller.parseDate=function(v,n,x){var i=new Date();if(!v||!n){return i}n=(typeof n=="object"?n.toString():n+"");var k=c.extend({},d,x),f=i.getFullYear(),z=i.getMonth()+1,t=i.getDate(),h=-1,w=i.getHours(),o=i.getMinutes(),g=0,l=-1,r=false,m=function(s){var B=(e+1<v.length&&v.charAt(e+1)==s);if(B){e++}return B},A=function(B){m(B);var C=(B=="@"?14:(B=="!"?20:(B=="y"?4:(B=="o"?3:2))));var D=new RegExp("^\\d{1,"+C+"}");var s=n.substr(u).match(D);if(!s){return 0}u+=s[0].length;return parseInt(s[0],10)},j=function(C,E,B){var F=(m(C)?B:E);for(var D=0;D<F.length;D++){if(n.substr(u,F[D].length).toLowerCase()==F[D].toLowerCase()){u+=F[D].length;return D+1}}return 0},q=function(){u++},u=0;for(var e=0;e<v.length;e++){if(r){if(v.charAt(e)=="'"&&!m("'")){r=false}else{q()}}else{switch(v.charAt(e)){case"d":t=A("d");break;case"D":j("D",k.dayNamesShort,k.dayNames);break;case"o":h=A("o");break;case"m":z=A("m");break;case"M":z=j("M",k.monthNamesShort,k.monthNames);break;case"y":f=A("y");break;case"H":w=A("H");break;case"h":w=A("h");break;case"i":o=A("i");break;case"s":g=A("s");break;case"a":l=j("a",["am","pm"],["am","pm"])-1;break;case"A":l=j("A",["am","pm"],["am","pm"])-1;break;case"'":if(m("'")){q()}else{r=true}break;default:q()}}}if(f<100){f+=new Date().getFullYear()-new Date().getFullYear()%100+(f<=k.shortYearCutoff?0:-100)}if(h>-1){z=1;t=h;do{var p=32-new Date(f,z-1,32).getDate();if(t<=p){break}z++;t-=p}while(true)}w=(l==-1)?w:((l&&w<12)?(w+12):(!l&&w==12?0:w));var y=new Date(f,z-1,t,w,o,g);if(y.getFullYear()!=f||y.getMonth()+1!=z||y.getDate()!=t){throw"Invalid date"}return y}})(jQuery);function getOffset(d) {y = d.getTimezoneOffset() * -1;s = (y<0 ? '-' : (y>0 ? '+' : 'Z'));h = Math.floor(Math.abs(y)/60);return (s === 'Z' ? s : s + pad(h,2) + ':' + pad(Math.abs(y%60),2)).trim();};function pad(num, size) {var s = "00" + num;return s.substr(s.length-size);}

		$(document).ready(function() {
			// Attach datescroller to date and time fields
			$(function(){
				$('.datetime').scroller({
					preset: 'datetime',
					theme: 'ios',
					display: 'modal',
					mode: 'scroller'
				});
				$('.date').scroller({
					preset: 'date',
					theme: 'ios',
					display: 'modal',
					mode: 'scroller'
				});
				$('body').on('change', '.date, .datetime', function() {
					$(this).val( $(this).val().trim());
				});

				// Attempt to get GeoLocation data on submit
				$(".atp, .sub").on('click', function(e) {
					if(navigator.geolocation)
						navigator.geolocation.getCurrentPosition(success,fail);
					return false;
				});
			});
		});
		function success(a){
			$("#long").val(a.coords.longitude);
			$("#lat").val(a.coords.latitude);
			$.mobile.silentScroll(0);
			_s();
		};
		function fail(){
			$("#long").attr("disabled","disabled");
			$("#lat").attr("disabled","disabled");
			$.mobile.silentScroll(0);
			_s();
		};
		function _s(){
			$('#status').html('Please wait while we fetch your pass');
			$('#passForm').submit();$('.formBody').html(' ');
		};
	</script>
</head>
<body>
<div data-role="page" id="newpass">
	<div data-role="header" data-position="fixed" data-tap-toggle="false">
			<h1><?php echo $pass_name; ?></h1>
	</div>

	<div data-role="content">
		<div class="ui-listview ui-listview-inset ui-corner-all ui-shadow" style="padding:8px 15px;margin-top:0;">
			<div class="iconImage"><img src="<?php echo $pass_image; ?>" alt="<?php echo $pass_name; ?>" /></div>
			<p class="passInst"><?php echo $pass_description?>
			<div class="clear"></div>
		</div>
		<div class="ui-listview ui-listview-inset ui-corner-all ui-shadow" style="padding:5px 15px;">
			<p class="passInst" id="status"><?php
			echo $pass_error ? '<span style="background:#f00;color:#fff;font-weight:bold;">&nbsp;Error:&nbsp;</span>&nbsp;' . $pass_error : 'Please enter your details below to create your pass'; ?></p>
			<div class="clear"></div>
		</div>
		<div class="formBody">
		<form id="passForm" name="passForm" data-ajax="false" action="https://<?php echo $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI']; ?>" method="POST" enctype="multipart/form-data">

		<?php

		foreach ($formFields as $field => $fields) {

			if ($fields['Field_type'] === 'label') {
				printf($input_template, $field .'_label', $fields['Field_label'], (isset($_POST[$field. '_label']) ? $_POST[$field. '_label'] : (isset($template[$field. '_label']['default']) ? $template[$field. '_label']['default'] : '')), '');
			}
			elseif ($fields['Field_type'] === 'data') {
				printf($input_template, $field, $fields['Field_label'], (isset($_POST[$field]) ? $_POST[$field] : (isset($template[$field]['default']) ? $template[$field]['default'] : '')), ' ' . $fields['Field_content']);
			}
			elseif ($fields['Field_type'] === 'backdata') {
				printf($textarea_template, $field, $fields['Field_label'], (isset($_POST[$field]) ? $_POST[$field] : (isset($template[$field]['default']) ? $template[$field]['default'] : '')), ' ' . $fields['Field_content']);
			}
			elseif ($fields['Field_type'] === 'image') {
				printf($image_template, $field, $fields['Field_label']);
			}

		}

?>
		<div class="ui-listview ui-listview-inset ui-corner-all ui-shadow" style="padding:5px 15px;">
			<p class="passInst"><?php
				echo 'If you want to install this pass on multiple devices, or want to be able to reinstall it in the event of accidential deletion or loss, please enter a valid email address below'; ?>
			</p>
			<div class="clear"></div>
		</div>
		<?php
		echo str_replace('type="text"', 'type="email"', str_replace('<em> *</em>', '', sprintf($input_template, 'recoveryEmail', 'Email Address', isset($_POST['recoveryEmail']) ? $_POST['recoveryEmail'] : '', '')));



		$ios6 = $pk->detect_passbook();

		if (($ios6)) {?>
			<div class="atp"> </div>

		<?php
		} elseif (!$ios6) {?>
	<div data-theme="d" data-role="button" class="sub"><?php echo 'Create Passbook Pass';?></div>

		 <?php } ?>

	<input id="lat" type="hidden" name="iLat" value="" />
	<input id="long" type="hidden" name="iLng" value="" />
	<input id="locd" type="hidden" name="iLoc" value="1" disabled="disabled" />
	</form>
	</div>
	</div>
	<div data-role="footer" data-theme="b" data-position="fixed" data-tap-toggle="false" data-id="pkf">
		 <h6><a href="http://passkit.com" title="Create Passbook Passes" rel="external" target="_blank" ><img src="https://d321ofrgjjwiwz.cloudfront.net/images/passkit_icon.svgz" alt="Create Passbook Passes" /> Created with PassKit</a></h6>
	</div>
</div>

</body>
</html>