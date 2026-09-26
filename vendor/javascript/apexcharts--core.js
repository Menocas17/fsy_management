// apexcharts/core@7.3.0 downloaded from https://ga.jspm.io/npm:apexcharts@7.3.0/dist/core.esm.js

var e=Object.defineProperty,t=Object.defineProperties,n=Object.getOwnPropertyDescriptors,r=Object.getOwnPropertySymbols,i=Object.prototype.hasOwnProperty,a=Object.prototype.propertyIsEnumerable,o=(t,n,r)=>n in t?e(t,n,{enumerable:!0,configurable:!0,writable:!0,value:r}):t[n]=r,s=(e,t)=>{for(var n in t||(t={}))i.call(t,n)&&o(e,n,t[n]);if(r)for(var n of r(t))a.call(t,n)&&o(e,n,t[n]);return e},c=(e,r)=>t(e,n(r)),u=(e,t,n)=>o(e,typeof t==`symbol`?t:t+``,n),d=(e,t,n)=>new Promise((r,i)=>{var a=e=>{try{s(n.next(e))}catch(e){i(e)}},o=e=>{try{s(n.throw(e))}catch(e){i(e)}},s=e=>e.done?r(e.value):Promise.resolve(e.value).then(a,o);s((n=n.apply(e,t)).next())});
/*!
* ApexCharts v7.3.0
* (c) 2018-2026 ApexCharts
*/
class Environment{static isSSR(){return typeof window>`u`||typeof document>`u`}static isBrowser(){return!this.isSSR()}static hasAPI(e){return this.isSSR()?!1:window[e]!==void 0}static getApex(){return typeof window<`u`&&window.Apex?window.Apex:typeof global<`u`&&global.Apex?global.Apex:{}}}class SSRElement{constructor(e,t=null){this.nodeName=e,this.namespaceURI=t,this.attributes=/* @__PURE__ */ new Map,this.children=[],this.textContent=``,this.style={},this.classList=new SSRClassList,this.parentNode=null,this._ssrWidth=void 0,this._ssrHeight=void 0,this._ssrMode=void 0}setAttribute(e,t){this.attributes.set(e,t)}getAttribute(e){return this.attributes.get(e)}removeAttribute(e){this.attributes.delete(e)}hasAttribute(e){return this.attributes.has(e)}appendChild(e){if(e&&e!==this){if(e.parentNode&&e.parentNode!==this)e.parentNode.removeChild(e);else if(e.parentNode===this){let t=this.children.indexOf(e);t!==-1&&this.children.splice(t,1)}e.parentNode=this,this.children.push(e)}return e}removeChild(e){let t=this.children.indexOf(e);return t!==-1&&(this.children.splice(t,1),e.parentNode=null),e}insertBefore(e,t){if(!t)return this.appendChild(e);if(e.parentNode&&e.parentNode!==this)e.parentNode.removeChild(e);else if(e.parentNode===this){let t=this.children.indexOf(e);t!==-1&&this.children.splice(t,1)}let n=this.children.indexOf(t);return n!==-1&&(e.parentNode=this,this.children.splice(n,0,e)),e}cloneNode(e=!1){let t=new SSRElement(this.nodeName,this.namespaceURI);return t.textContent=this.textContent,this.attributes.forEach((e,n)=>{t.attributes.set(n,e)}),Object.assign(t.style,this.style),e&&this.children.forEach(e=>{e.cloneNode&&t.appendChild(e.cloneNode(!0))}),t}getBoundingClientRect(){return{width:this._ssrWidth||0,height:this._ssrHeight||0,top:0,left:0,right:this._ssrWidth||0,bottom:this._ssrHeight||0,x:0,y:0}}getRootNode(){let e=this;for(;e.parentNode;)e=e.parentNode;return e}querySelector(){return null}querySelectorAll(){return[]}getElementsByClassName(){return[]}addEventListener(){}removeEventListener(){}get childNodes(){return this.children}toString(){let e=``;if(this.attributes.forEach((t,n)=>{e+=` ${n}="${t}"`}),this.children.length===0&&!this.textContent)return`<${this.nodeName}${e}/>`;let t=this.children.map(e=>e.toString()).join(``);return`<${this.nodeName}${e}>${this.textContent}${t}</${this.nodeName}>`}get innerHTML(){return this.children.map(e=>e.toString()).join(``)}set innerHTML(e){this.children=[],this.textContent=e}get outerHTML(){return this.toString()}get isConnected(){return!0}}class SSRClassList{constructor(){this.classes=/* @__PURE__ */ new Set}add(...e){e.forEach(e=>this.classes.add(e))}remove(...e){e.forEach(e=>this.classes.delete(e))}contains(e){return this.classes.has(e)}toggle(e,t){return t===!0?(this.classes.add(e),!0):t===!1||this.classes.has(e)?(this.classes.delete(e),!1):(this.classes.add(e),!0)}toString(){return Array.from(this.classes).join(` `)}}class SSRDOMShim{constructor(){this.SVGNS=`http://www.w3.org/2000/svg`,this.XLINKNS=`http://www.w3.org/1999/xlink`}createElementNS(e,t){return new SSRElement(t,e)}createTextNode(e){let t={nodeName:`#text`,nodeType:3,textContent:e,toString(){return t.textContent}};return t}querySelector(){return null}querySelectorAll(){return[]}getComputedStyle(){return{}}getBoundingClientRect(e){return e&&e.getBoundingClientRect?e.getBoundingClientRect():{width:0,height:0,top:0,left:0,right:0,bottom:0,x:0,y:0}}createXMLSerializer(){return{serializeToString(e){return e.toString?e.toString():``}}}createDOMParser(){return{parseFromString(e,t){let n=new SSRElement(`root`);return n.innerHTML=e,{documentElement:n}}}}}let f=null,p=null,m=null;class BrowserAPIs{static init(){Environment.isSSR()&&!f&&(f=new SSRDOMShim)}static createElement(e){return Environment.isSSR()?(f||this.init(),f.createElementNS(null,e)):document.createElement(e)}static createElementNS(e,t){return Environment.isSSR()?(f||this.init(),f.createElementNS(e,t)):document.createElementNS(e,t)}static createTextNode(e){return Environment.isSSR()?(f||this.init(),f.createTextNode(e)):document.createTextNode(e)}static querySelector(e){return Environment.isSSR()?null:document.querySelector(e)}static querySelectorAll(e){return Environment.isSSR()?[]:document.querySelectorAll(e)}static getComputedStyle(e){return Environment.isSSR()?{}:window.getComputedStyle(e)}static matchMedia(e){if(Environment.isSSR()||typeof window.matchMedia!=`function`)return null;try{return window.matchMedia(e)}catch(e){return null}}static getBoundingClientRect(e){return Environment.isSSR()?(f||this.init(),f.getBoundingClientRect(e)):e?e.getBoundingClientRect():{width:0,height:0,top:0,left:0,right:0,bottom:0,x:0,y:0}}static getXMLSerializer(){return Environment.isSSR()?(f||this.init(),p||(p=f.createXMLSerializer()),p):(p||(p=new XMLSerializer),p)}static getDOMParser(){return Environment.isSSR()?(f||this.init(),m||(m=f.createDOMParser()),m):(m||(m=new DOMParser),m)}static addWindowEventListener(e,t,n){Environment.isBrowser()&&window.addEventListener(e,t,n)}static removeWindowEventListener(e,t,n){Environment.isBrowser()&&window.removeEventListener(e,t,n)}static requestAnimationFrame(e){return Environment.isBrowser()?window.requestAnimationFrame(e):(e(0),null)}static cancelAnimationFrame(e){Environment.isBrowser()&&e&&window.cancelAnimationFrame(e)}static elementExists(e){return e?Environment.isSSR()?e._ssrMode===!0||e.nodeName!==void 0:e.getRootNode?e.getRootNode({composed:!0})===document||e.isConnected:!1:!1}static getWindow(){return Environment.isBrowser()?window:null}static getDocument(){return Environment.isBrowser()?document:null}static _getShim(){return f}static _resetShim(){f=null,p=null,m=null}}const h=/* @__PURE__ */ new WeakMap;let g=0,_=class Utils{static isObject(e){return e&&typeof e==`object`&&!Array.isArray(e)}static is(e,t){return Object.prototype.toString.call(t)===`[object `+e+`]`}static isSafari(){return Environment.isBrowser()&&/^((?!chrome|android).)*safari/i.test(navigator.userAgent)}static extend(e,t){if(!this.isObject(e)&&this.isObject(t))return this.clone(t);let n=Object.assign({},e);return this.isObject(e)&&this.isObject(t)&&Object.keys(t).forEach(r=>{this.isObject(t[r])&&r in e?n[r]=this.extend(e[r],t[r]):Object.assign(n,{[r]:t[r]})}),n}static copySeriesShallow(e){return Array.isArray(e)?e.map(e=>this.isObject(e)?s({},e):e):e}static extendArray(e,t){let n=[];return e.map(e=>{n.push(Utils.extend(t,e))}),e=n,e}static monthMod(e){return e%12}static clone(e,t=/* @__PURE__ */ new WeakMap,n=!1){if(typeof e!=`object`||!e)return e;if(t.has(e))return t.get(e);let r;if(Array.isArray(e))if(n)r=e.slice();else{r=[],t.set(e,r);for(let n=0;n<e.length;n++)r[n]=this.clone(e[n],t,!1)}else if(e instanceof Date)r=new Date(e.getTime());else if(n)r=Object.assign({},e);else{r={},t.set(e,r);for(let n in e)Object.prototype.hasOwnProperty.call(e,n)&&(r[n]=this.clone(e[n],t,!1))}return r}static shallowClone(e){return typeof e!=`object`||!e?e:Array.isArray(e)?e.slice():Object.assign({},e)}static stringifyForCompare(e){return JSON.stringify(e,(e,t)=>{if(typeof t!=`function`)return t;let n=h.get(t);return n===void 0&&(n=++g,h.set(t,n)),`__apx_fn_${n}`})}static shallowEqual(e,t){if(e===t)return!0;if(!e||!t)return!1;if(typeof e!=`object`||typeof t!=`object`)return e===t;let n=Object.keys(e),r=Object.keys(t);if(n.length!==r.length)return!1;for(let r of n)if(e[r]!==t[r])return!1;return!0}static log10(e){return Math.log(e)/Math.LN10}static roundToBase10(e){return 10**Math.floor(Math.log10(e))}static roundToBase(e,t){return t**+Math.floor(Math.log(e)/Math.log(t))}static parseNumber(e){return typeof e==`number`||e===null?e:parseFloat(e)}static stripNumber(e,t=2){return Number.isInteger(e)?e:parseFloat(e.toPrecision(t))}static randomId(){return(Math.random()+1).toString(36).substring(4)}static noExponents(e){return e.toString().includes(`e`)?Math.round(e):e}static elementExists(e){return!(!e||!e.isConnected)}static getDimensions(e){if(!e)return[0,0];if(Environment.isSSR())return[e._ssrWidth||400,e._ssrHeight||300];let t;try{t=getComputedStyle(e,null)}catch(t){return[e.clientWidth||0,e.clientHeight||0]}let n=e.clientWidth,r=e.clientHeight;if(!n||!r){let t=e.getBoundingClientRect();n=n||t.width,r=r||t.height}return r-=parseFloat(t.paddingTop)+parseFloat(t.paddingBottom),n-=parseFloat(t.paddingLeft)+parseFloat(t.paddingRight),[n,r]}static getBoundingClientRect(e){if(!e)return{top:0,right:0,bottom:0,left:0,width:0,height:0,x:0,y:0};if(Environment.isSSR())return BrowserAPIs.getBoundingClientRect(e);let t=e.getBoundingClientRect();return{top:t.top,right:t.right,bottom:t.bottom,left:t.left,width:e.clientWidth,height:e.clientHeight,x:t.left,y:t.top}}static getLargestStringFromArr(e){return e.reduce((e,t)=>(Array.isArray(t)&&(t=t.reduce((e,t)=>e.length>t.length?e:t)),e.length>t.length?e:t),0)}static hexToRgba(e=`#999999`,t=.6){e.substring(0,1)!==`#`&&(e=`#999999`);let n=e.replace(`#`,``),r=n.match(RegExp(`(.{`+n.length/3+`})`,`g`))||[];for(let e=0;e<r.length;e++)r[e]=parseInt(r[e].length===1?r[e]+r[e]:r[e],16);return t!==void 0&&r.push(t),`rgba(`+r.join(`,`)+`)`}static getOpacityFromRGBA(e){return parseFloat(e.replace(/^.*,(.+)\)/,`$1`))}static parseHex(e){if(typeof e!=`string`)return null;let t=e.trim().replace(`#`,``);return t.length===3&&(t=t.split(``).map(e=>e+e).join(``)),/^[0-9a-fA-F]{6}$/.test(t)?[parseInt(t.slice(0,2),16),parseInt(t.slice(2,4),16),parseInt(t.slice(4,6),16)]:null}static relativeLuminance([e,t,n]){let r=e=>{let t=e/255;return t<=.03928?t/12.92:((t+.055)/1.055)**2.4};return .2126*r(e)+.7152*r(t)+.0722*r(n)}static getContrastRatio(e,t){let n=Utils.parseHex(e),r=Utils.parseHex(t);if(!n||!r)return 0;let i=Utils.relativeLuminance(n),a=Utils.relativeLuminance(r),o=Math.max(i,a),s=Math.min(i,a);return(o+.05)/(s+.05)}static rgb2hex(e){return e=e.match(/^rgba?[\s+]?\([\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?,[\s+]?(\d+)[\s+]?/i),e&&e.length===4?`#`+(`0`+parseInt(e[1],10).toString(16)).slice(-2)+(`0`+parseInt(e[2],10).toString(16)).slice(-2)+(`0`+parseInt(e[3],10).toString(16)).slice(-2):``}shadeRGBColor(e,t){let n=t.split(`,`),r=e<0?0:255,i=e<0?e*-1:e,a=parseInt(n[0].slice(4),10),o=parseInt(n[1],10),s=parseInt(n[2],10);return`rgb(`+(Math.round((r-a)*i)+a)+`,`+(Math.round((r-o)*i)+o)+`,`+(Math.round((r-s)*i)+s)+`)`}shadeHexColor(e,t){let n=parseInt(t.slice(1),16),r=e<0?0:255,i=e<0?e*-1:e,a=n>>16,o=n>>8&255,s=n&255;return`#`+(16777216+(Math.round((r-a)*i)+a)*65536+(Math.round((r-o)*i)+o)*256+(Math.round((r-s)*i)+s)).toString(16).slice(1)}shadeColor(e,t){return Utils.isColorHex(t)?this.shadeHexColor(e,t):this.shadeRGBColor(e,t)}static isColorHex(e){return/(^#[0-9A-F]{6}$)|(^#[0-9A-F]{3}$)|(^#[0-9A-F]{8}$)/i.test(e)}static isCSSVariable(e){if(typeof e!=`string`)return!1;let t=e.trim();return t.startsWith(`var(`)&&t.endsWith(`)`)}static getThemeColor(e){if(!Utils.isCSSVariable(e)||Environment.isSSR())return e;let t=document.createElement(`div`);t.style.cssText=`position:fixed; left: -9999px; visibility:hidden;`,t.style.color=e,document.body.appendChild(t);let n;try{n=window.getComputedStyle(t).color}finally{t.parentNode&&t.parentNode.removeChild(t)}return n}static applyOpacityToColor(e,t){let n=Number(t);return Number.isFinite(n)?n<=0?`transparent`:n>=1?e:`color-mix(in srgb, ${e} ${Math.round(n*100)}%, transparent)`:e}static getPolygonPos(e,t){let n=[],r=Math.PI*2/t;for(let i=0;i<t;i++){let t={};t.x=e*Math.sin(i*r),t.y=-e*Math.cos(i*r),n.push(t)}return n}static polarToCartesian(e,t,n,r){let i=(r-90)*Math.PI/180;return{x:e+n*Math.cos(i),y:t+n*Math.sin(i)}}static escapeString(e,t=`x`){let n=e.toString().slice();return n=n.replace(/[` ~!@#$%^&*()|+=?;:'",.<>{}[\]\\/]/gi,t),n}static negToZero(e){return e<0?0:e}static moveIndexInArray(e,t,n){if(n>=e.length){let t=n-e.length+1;for(;t--;)e.push(void 0)}return e.splice(n,0,e.splice(t,1)[0]),e}static extractNumber(e){return parseFloat(e.replace(/[^\d.]*/g,``))}static findAncestor(e,t){for(;(e=e.parentElement)&&!e.classList.contains(t););return e}static setELstyles(e,t){for(let n in t)Object.prototype.hasOwnProperty.call(t,n)&&(e.style[n]=t[n])}static preciseAddition(e,t){let n=(String(e).split(`.`)[1]||``).length,r=(String(t).split(`.`)[1]||``).length,i=10**Math.max(n,r);return(Math.round(e*i)+Math.round(t*i))/i}static isNumber(e){return!isNaN(e)&&parseFloat(String(Number(e)))===e&&!isNaN(parseInt(e,10))}static isFloat(e){return Number(e)===e&&e%1!=0}static isMsEdge(){if(Environment.isSSR())return!1;let e=window.navigator.userAgent,t=e.indexOf(`Edge/`);return t>0?parseInt(e.substring(t+5,e.indexOf(`.`,t)),10):!1}static getGCD(e,t,n=7){let r=10**(n-Math.floor(Math.log10(Math.max(e,t))));for(r>1?(e=Math.round(Math.abs(e)*r),t=Math.round(Math.abs(t)*r)):r=1;t;){let n=t;t=e%t,e=n}return e/r}static getPrimeFactors(e){let t=[],n=2;for(;e>=2;)e%n==0?(t.push(n),e/=n):n++;return t}static mod(e,t,n=7){let r=10**(n-Math.floor(Math.log10(Math.max(e,t))));return e=Math.round(Math.abs(e)*r),t=Math.round(Math.abs(t)*r),e%t/r}};class DateTime{constructor(e){this.w=e,this.months31=[1,3,5,7,8,10,12],this.months30=[2,4,6,9,11],this.daysCntOfYear=[0,31,59,90,120,151,181,212,243,273,304,334]}isValidDate(e){return typeof e==`number`?!1:!isNaN(this.parseDate(e))}getTimeStamp(e){return isNaN(Date.parse(e))?e:this.w.config.xaxis.labels.datetimeUTC?new Date(new Date(e).toISOString().substr(0,25)).getTime():new Date(e).getTime()}getDate(e){return this.w.config.xaxis.labels.datetimeUTC?new Date(new Date(e).toUTCString()):new Date(e)}parseDate(e){if(!isNaN(Date.parse(e)))return this.getTimeStamp(e);if(typeof e!=`string`)return NaN;let t=Date.parse(e.replace(/-/g,`/`).replace(/[a-z]+/gi,` `));return t=this.getTimeStamp(t),t}parseDateWithTimezone(e){return Date.parse(e.replace(/-/g,`/`).replace(/[a-z]+/gi,` `))}formatDate(e,t){let n=this.w.globals.locale,r=this.w.config.xaxis.labels.datetimeUTC,i=[`\0`,...n.months],a=[``,...n.shortMonths],o=[``,...n.days],s=[``,...n.shortDays];function c(e,t=2){let n=e+``;for(;n.length<t;)n=`0`+n;return n}let u=r?e.getUTCFullYear():e.getFullYear();t=t.replace(/(^|[^\\])yyyy+/g,`$1`+u),t=t.replace(/(^|[^\\])yy/g,`$1`+u.toString().substr(2,2)),t=t.replace(/(^|[^\\])y/g,`$1`+u);let d=(r?e.getUTCMonth():e.getMonth())+1;t=t.replace(/(^|[^\\])MMMM+/g,`$1`+i[0]),t=t.replace(/(^|[^\\])MMM/g,`$1`+a[0]),t=t.replace(/(^|[^\\])MM/g,`$1`+c(d)),t=t.replace(/(^|[^\\])M/g,`$1`+d);let f=r?e.getUTCDate():e.getDate();t=t.replace(/(^|[^\\])dddd+/g,`$1`+o[0]),t=t.replace(/(^|[^\\])ddd/g,`$1`+s[0]),t=t.replace(/(^|[^\\])dd/g,`$1`+c(f)),t=t.replace(/(^|[^\\])d/g,`$1`+f);let p=r?e.getUTCHours():e.getHours();t=t.replace(/(^|[^\\])HH+/g,`$1`+c(p)),t=t.replace(/(^|[^\\])H/g,`$1`+p);let m=p>12?p-12:p===0?12:p;t=t.replace(/(^|[^\\])hh+/g,`$1`+c(m)),t=t.replace(/(^|[^\\])h/g,`$1`+m);let h=r?e.getUTCMinutes():e.getMinutes();t=t.replace(/(^|[^\\])mm+/g,`$1`+c(h)),t=t.replace(/(^|[^\\])m/g,`$1`+h);let g=r?e.getUTCSeconds():e.getSeconds();t=t.replace(/(^|[^\\])ss+/g,`$1`+c(g)),t=t.replace(/(^|[^\\])s/g,`$1`+g);let _=r?e.getUTCMilliseconds():e.getMilliseconds();t=t.replace(/(^|[^\\])fff+/g,`$1`+c(_,3)),_=Math.round(_/10),t=t.replace(/(^|[^\\])ff/g,`$1`+c(_)),_=Math.round(_/10),t=t.replace(/(^|[^\\])f/g,`$1`+_);let v=p<12?`AM`:`PM`;t=t.replace(/(^|[^\\])TT+/g,`$1`+v),t=t.replace(/(^|[^\\])T/g,`$1`+v.charAt(0));let y=v.toLowerCase();t=t.replace(/(^|[^\\])tt+/g,`$1`+y),t=t.replace(/(^|[^\\])t/g,`$1`+y.charAt(0));let b=-e.getTimezoneOffset(),x=r||!b?`Z`:b>0?`+`:`-`;if(!r){b=Math.abs(b);let e=Math.floor(b/60),t=b%60;x+=c(e)+`:`+c(t)}t=t.replace(/(^|[^\\])K/g,`$1`+x);let S=(r?e.getUTCDay():e.getDay())+1;return t=t.replace(new RegExp(o[0],`g`),o[S]),t=t.replace(new RegExp(s[0],`g`),s[S]),t=t.replace(new RegExp(i[0],`g`),i[d]),t=t.replace(new RegExp(a[0],`g`),a[d]),t=t.replace(/\\(.)/g,`$1`),t}getTimeUnitsfromTimestamp(e,t){let n=this.w;n.config.xaxis.min!==void 0&&(e=n.config.xaxis.min),n.config.xaxis.max!==void 0&&(t=n.config.xaxis.max);let r=this.getDate(e),i=this.getDate(t),a=this.formatDate(r,`yyyy MM dd HH mm ss fff`).split(` `),o=this.formatDate(i,`yyyy MM dd HH mm ss fff`).split(` `);return{minMillisecond:parseInt(a[6],10),maxMillisecond:parseInt(o[6],10),minSecond:parseInt(a[5],10),maxSecond:parseInt(o[5],10),minMinute:parseInt(a[4],10),maxMinute:parseInt(o[4],10),minHour:parseInt(a[3],10),maxHour:parseInt(o[3],10),minDate:parseInt(a[2],10),maxDate:parseInt(o[2],10),minMonth:parseInt(a[1],10)-1,maxMonth:parseInt(o[1],10)-1,minYear:parseInt(a[0],10),maxYear:parseInt(o[0],10)}}isLeapYear(e){return e%4==0&&e%100!=0||e%400==0}calculcateLastDaysOfMonth(e,t,n){return this.determineDaysOfMonths(e,t)-n}determineDaysOfYear(e){let t=365;return this.isLeapYear(e)&&(t=366),t}determineRemainingDaysOfYear(e,t,n){let r=this.daysCntOfYear[t]+n;return t>1&&this.isLeapYear(e)&&r++,r}determineDaysOfMonths(e,t){let n=30;switch(e=_.monthMod(e),!0){case this.months30.indexOf(e)>-1:e===2&&(n=this.isLeapYear(t)?29:28);break;case this.months31.indexOf(e)>-1:n=31;break;default:n=31;break}return n}getDateFields(e,t){let n=new Date(e);return t?{year:n.getUTCFullYear(),month:n.getUTCMonth(),date:n.getUTCDate(),hour:n.getUTCHours(),minute:n.getUTCMinutes(),second:n.getUTCSeconds(),ms:n.getUTCMilliseconds(),weekday:n.getUTCDay()}:{year:n.getFullYear(),month:n.getMonth(),date:n.getDate(),hour:n.getHours(),minute:n.getMinutes(),second:n.getSeconds(),ms:n.getMilliseconds(),weekday:n.getDay()}}addInterval(e,t,n,r){let i=new Date(e);if(r)switch(t){case`year`:i.setUTCFullYear(i.getUTCFullYear()+n);break;case`month`:i.setUTCMonth(i.getUTCMonth()+n);break;case`week`:i.setUTCDate(i.getUTCDate()+n*7);break;case`day`:i.setUTCDate(i.getUTCDate()+n);break;case`hour`:i.setUTCHours(i.getUTCHours()+n);break;case`minute`:i.setUTCMinutes(i.getUTCMinutes()+n);break;case`second`:i.setUTCSeconds(i.getUTCSeconds()+n);break}else switch(t){case`year`:i.setFullYear(i.getFullYear()+n);break;case`month`:i.setMonth(i.getMonth()+n);break;case`week`:i.setDate(i.getDate()+n*7);break;case`day`:i.setDate(i.getDate()+n);break;case`hour`:i.setHours(i.getHours()+n);break;case`minute`:i.setMinutes(i.getMinutes()+n);break;case`second`:i.setSeconds(i.getSeconds()+n);break}return i.getTime()}ceilToBoundary(e,t,n,r){let i=new Date(e);if(r)switch(t){case`second`:{let t=i.getUTCSeconds(),r=Math.ceil(t/n)*n;return r===t&&i.getUTCMilliseconds()===0?e:(i.setUTCMilliseconds(0),i.setUTCSeconds(r),i.getTime())}case`minute`:{let t=i.getUTCMinutes(),r=Math.ceil(t/n)*n;return r===t&&i.getUTCSeconds()===0&&i.getUTCMilliseconds()===0?e:(i.setUTCMilliseconds(0),i.setUTCSeconds(0),i.setUTCMinutes(r),i.getTime())}case`hour`:{let t=i.getUTCHours(),r=Math.ceil(t/n)*n;return r===t&&i.getUTCMinutes()===0&&i.getUTCSeconds()===0&&i.getUTCMilliseconds()===0?e:(i.setUTCMilliseconds(0),i.setUTCSeconds(0),i.setUTCMinutes(0),i.setUTCHours(r),i.getTime())}case`day`:return i.getUTCHours()===0&&i.getUTCMinutes()===0&&i.getUTCSeconds()===0&&i.getUTCMilliseconds()===0?e:(i.setUTCMilliseconds(0),i.setUTCSeconds(0),i.setUTCMinutes(0),i.setUTCHours(0),i.setUTCDate(i.getUTCDate()+1),i.getTime());case`week`:{let t=10080*60*1e3,r=Date.UTC(1970,0,5);i.setUTCMilliseconds(0),i.setUTCSeconds(0),i.setUTCMinutes(0),i.setUTCHours(0);let a=i.getTime(),o=Math.ceil((a-r)/t),s=r+Math.ceil(o/n)*n*t;return s>=e?s:s+n*t}case`month`:{let t=i.getUTCMonth(),r=Math.ceil(t/n)*n;return r===t&&i.getUTCDate()===1&&i.getUTCHours()===0&&i.getUTCMinutes()===0&&i.getUTCSeconds()===0&&i.getUTCMilliseconds()===0?e:(i.setUTCMilliseconds(0),i.setUTCSeconds(0),i.setUTCMinutes(0),i.setUTCHours(0),i.setUTCDate(1),i.setUTCMonth(r),i.getTime())}case`year`:{let t=i.getUTCFullYear(),r=Math.ceil(t/n)*n;return r===t&&i.getUTCMonth()===0&&i.getUTCDate()===1&&i.getUTCHours()===0&&i.getUTCMinutes()===0&&i.getUTCSeconds()===0&&i.getUTCMilliseconds()===0?e:Date.UTC(r,0,1)}}else switch(t){case`second`:{let t=i.getSeconds(),r=Math.ceil(t/n)*n;return r===t&&i.getMilliseconds()===0?e:(i.setMilliseconds(0),i.setSeconds(r),i.getTime())}case`minute`:{let t=i.getMinutes(),r=Math.ceil(t/n)*n;return r===t&&i.getSeconds()===0&&i.getMilliseconds()===0?e:(i.setMilliseconds(0),i.setSeconds(0),i.setMinutes(r),i.getTime())}case`hour`:{let t=i.getHours(),r=Math.ceil(t/n)*n;return r===t&&i.getMinutes()===0&&i.getSeconds()===0&&i.getMilliseconds()===0?e:(i.setMilliseconds(0),i.setSeconds(0),i.setMinutes(0),i.setHours(r),i.getTime())}case`day`:return i.getHours()===0&&i.getMinutes()===0&&i.getSeconds()===0&&i.getMilliseconds()===0?e:(i.setMilliseconds(0),i.setSeconds(0),i.setMinutes(0),i.setHours(0),i.setDate(i.getDate()+1),i.getTime());case`week`:{let t=10080*60*1e3,r=new Date(1970,0,5).getTime();i.setMilliseconds(0),i.setSeconds(0),i.setMinutes(0),i.setHours(0);let a=i.getTime(),o=Math.ceil((a-r)/t),s=r+Math.ceil(o/n)*n*t;return s>=e?s:s+n*t}case`month`:{let t=i.getMonth(),r=Math.ceil(t/n)*n;return r===t&&i.getDate()===1&&i.getHours()===0&&i.getMinutes()===0&&i.getSeconds()===0&&i.getMilliseconds()===0?e:(i.setMilliseconds(0),i.setSeconds(0),i.setMinutes(0),i.setHours(0),i.setDate(1),i.setMonth(r),i.getTime())}case`year`:{let t=i.getFullYear(),r=Math.ceil(t/n)*n;return r===t&&i.getMonth()===0&&i.getDate()===1&&i.getHours()===0&&i.getMinutes()===0&&i.getSeconds()===0&&i.getMilliseconds()===0?e:new Date(r,0,1).getTime()}}return e}isAtBoundary(e,t,n){let r=this.getDateFields(e,n);switch(t){case`year`:return r.month===0&&r.date===1&&r.hour===0&&r.minute===0&&r.second===0&&r.ms===0;case`month`:return r.date===1&&r.hour===0&&r.minute===0&&r.second===0&&r.ms===0;case`day`:return r.hour===0&&r.minute===0&&r.second===0&&r.ms===0;case`hour`:return r.minute===0&&r.second===0&&r.ms===0;case`minute`:return r.second===0&&r.ms===0;case`second`:return r.ms===0}return!1}}class Formatters{constructor(e){this.w=e,this.tooltipKeyFormat=`dd MMM`}xLabelFormat(e,t,n,r){let i=this.w;if(i.config.xaxis.type===`datetime`&&i.config.xaxis.labels.formatter===void 0&&i.config.tooltip.x.formatter===void 0){let e=new DateTime(this.w);return e.formatDate(e.getDate(t),i.config.tooltip.x.format)}return e(t,n,r)}defaultGeneralFormatter(e){return Array.isArray(e)?e.map(e=>e):e}defaultYFormatter(e,t){let n=this.w;if(_.isNumber(e))if(n.globals.yValueDecimal!==0)e=e.toFixed(t.decimalsInFloat===void 0?n.globals.yValueDecimal:t.decimalsInFloat);else{let t=e.toFixed(0);e=Number(t)===e?t:e.toFixed(1)}return e}setLabelFormatters(){let e=this.w,t=e.formatters;return t.xaxisTooltipFormatter=e=>this.defaultGeneralFormatter(e),t.ttKeyFormatter=e=>this.defaultGeneralFormatter(e),t.ttZFormatter=e=>e,t.legendFormatter=e=>this.defaultGeneralFormatter(e),e.config.xaxis.labels.formatter===void 0?t.xLabelFormatter=t=>{if(_.isNumber(t)){if(!e.config.xaxis.convertedCatToNumeric&&e.config.xaxis.type===`numeric`){if(_.isNumber(e.config.xaxis.decimalsInFloat))return t.toFixed(e.config.xaxis.decimalsInFloat);{let n=e.globals.maxX-e.globals.minX;if(n>0){let e=n/10,r=Math.max(0,-Math.floor(Math.log10(e)));return t.toFixed(r)}return t.toFixed(0)}}return e.globals.isBarHorizontal&&e.globals.maxY-e.globals.minY<4?t.toFixed(1):t.toFixed(0)}return t}:t.xLabelFormatter=e.config.xaxis.labels.formatter,typeof e.config.tooltip.x.formatter==`function`?t.ttKeyFormatter=e.config.tooltip.x.formatter:t.ttKeyFormatter=t.xLabelFormatter,typeof e.config.xaxis.tooltip.formatter==`function`&&(t.xaxisTooltipFormatter=e.config.xaxis.tooltip.formatter),(Array.isArray(e.config.tooltip.y)||e.config.tooltip.y.formatter!==void 0)&&(t.ttVal=e.config.tooltip.y),e.config.tooltip.z.formatter!==void 0&&(t.ttZFormatter=e.config.tooltip.z.formatter),e.config.legend.formatter!==void 0&&(t.legendFormatter=e.config.legend.formatter),t.yLabelFormatters=[],e.config.yaxis.forEach((n,r)=>{if(n.labels.formatter!==void 0)t.yLabelFormatters[r]=n.labels.formatter;else if(e.config.chart.type===`violin`){let n=e=>typeof e==`number`&&isFinite(e)?`${Math.round(e*100)/100}`:e;t.yLabelFormatters[r]=t=>e.globals.xyCharts?Array.isArray(t)?t.map(n):n(t):t}else t.yLabelFormatters[r]=t=>e.globals.xyCharts?Array.isArray(t)?t.map(e=>this.defaultYFormatter(e,n)):this.defaultYFormatter(t,n):t}),e.globals}heatmapLabelFormatters(){let e=this.w;if(e.config.chart.type===`heatmap`){e.globals.yAxisScale[0].result=e.seriesData.seriesNames.slice();let t=e.seriesData.seriesNames.reduce((e,t)=>e.length>t.length?e:t,0);e.globals.yAxisScale[0].niceMax=t,e.globals.yAxisScale[0].niceMin=t}}}const v=`en`,y={name:`en`,options:{months:[`January`,`February`,`March`,`April`,`May`,`June`,`July`,`August`,`September`,`October`,`November`,`December`],shortMonths:[`Jan`,`Feb`,`Mar`,`Apr`,`May`,`Jun`,`Jul`,`Aug`,`Sep`,`Oct`,`Nov`,`Dec`],days:[`Sunday`,`Monday`,`Tuesday`,`Wednesday`,`Thursday`,`Friday`,`Saturday`],shortDays:[`Sun`,`Mon`,`Tue`,`Wed`,`Thu`,`Fri`,`Sat`],toolbar:{exportToSVG:`Download SVG`,exportToPNG:`Download PNG`,exportToCSV:`Download CSV`,menu:`Menu`,selection:`Selection`,selectionZoom:`Selection Zoom`,zoomIn:`Zoom In`,zoomOut:`Zoom Out`,pan:`Panning`,reset:`Reset Zoom`,measure:`Measure`}}};class Options{constructor(){this.yAxis={show:!0,showAlways:!1,showForNullSeries:!0,seriesName:void 0,opposite:!1,reversed:!1,logarithmic:!1,logBase:10,tickAmount:void 0,stepSize:void 0,forceNiceScale:!1,alignZero:!1,max:void 0,min:void 0,floating:!1,decimalsInFloat:void 0,labels:{show:!0,showDuplicates:!1,minWidth:0,maxWidth:160,offsetX:0,offsetY:0,align:void 0,rotate:0,padding:20,style:{colors:[],fontSize:`11px`,fontWeight:400,fontFamily:void 0,cssClass:``},formatter:void 0},axisBorder:{show:!1,color:`#e0e0e0`,width:1,offsetX:0,offsetY:0},axisTicks:{show:!1,color:`#e0e0e0`,width:6,offsetX:0,offsetY:0},title:{text:void 0,rotate:-90,offsetY:0,offsetX:0,style:{color:void 0,fontSize:`11px`,fontWeight:900,fontFamily:void 0,cssClass:``}},tooltip:{enabled:!1,offsetX:0},crosshairs:{show:!0,position:`front`,stroke:{color:`#b6b6b6`,width:1,dashArray:0}}},this.pointAnnotation={id:void 0,x:0,y:null,yAxisIndex:0,seriesIndex:void 0,mouseEnter:void 0,mouseLeave:void 0,click:void 0,marker:{size:4,fillColor:`#fff`,strokeWidth:2,strokeColor:`#333`,shape:`circle`,offsetX:0,offsetY:0,cssClass:``},label:{borderColor:`#c2c2c2`,borderWidth:1,borderRadius:2,text:void 0,textAnchor:`middle`,offsetX:0,offsetY:0,mouseEnter:void 0,mouseLeave:void 0,click:void 0,style:{background:`#fff`,color:void 0,fontSize:`11px`,fontFamily:void 0,fontWeight:400,cssClass:``,padding:{left:5,right:5,top:2,bottom:2}}},customSVG:{SVG:void 0,cssClass:void 0,offsetX:0,offsetY:0},image:{path:void 0,width:20,height:20,offsetX:0,offsetY:0},tooltip:{enabled:!1,text:void 0,formatter:void 0,theme:void 0,offsetX:0,offsetY:0}},this.yAxisAnnotation={id:void 0,y:0,y2:null,strokeDashArray:1,fillColor:`#c2c2c2`,borderColor:`#c2c2c2`,borderWidth:1,opacity:.3,offsetX:0,offsetY:0,width:`100%`,yAxisIndex:0,label:{borderColor:`#c2c2c2`,borderWidth:1,borderRadius:2,text:void 0,textAnchor:`end`,position:`right`,offsetX:0,offsetY:-3,mouseEnter:void 0,mouseLeave:void 0,click:void 0,style:{background:`#fff`,color:void 0,fontSize:`11px`,fontFamily:void 0,fontWeight:400,cssClass:``,padding:{left:5,right:5,top:2,bottom:2}}}},this.xAxisAnnotation={id:void 0,x:0,x2:null,strokeDashArray:1,fillColor:`#c2c2c2`,borderColor:`#c2c2c2`,borderWidth:1,opacity:.3,offsetX:0,offsetY:0,label:{borderColor:`#c2c2c2`,borderWidth:1,borderRadius:2,text:void 0,textAnchor:`middle`,orientation:`vertical`,position:`top`,offsetX:0,offsetY:0,mouseEnter:void 0,mouseLeave:void 0,click:void 0,style:{background:`#fff`,color:void 0,fontSize:`11px`,fontFamily:void 0,fontWeight:400,cssClass:``,padding:{left:5,right:5,top:2,bottom:2}}}},this.text={x:0,y:0,text:``,textAnchor:`start`,foreColor:void 0,fontSize:`13px`,fontFamily:void 0,fontWeight:400,appendTo:`.apexcharts-annotations`,backgroundColor:`transparent`,borderColor:`#c2c2c2`,borderRadius:0,borderWidth:0,paddingLeft:4,paddingRight:4,paddingTop:2,paddingBottom:2}}init(){return{annotations:{yaxis:[this.yAxisAnnotation],xaxis:[this.xAxisAnnotation],points:[this.pointAnnotation],texts:[],images:[],shapes:[]},plugins:[],trellis:{by:void 0,row:void 0,column:void 0,emptyPanels:`placeholder`,data:void 0,x:void 0,y:void 0,seriesBy:void 0,columns:`auto`,minPanelWidth:220,gap:12,aspectRatio:1.6,panelHeight:void 0,order:`first-seen`,limit:void 0,virtualize:`auto`,scales:{x:`shared`,y:`shared`,color:`shared`,size:`shared`},header:{show:!0,formatter:void 0,style:{fontSize:void 0,fontWeight:void 0,color:void 0}},axes:{labels:`edges`},legend:`shared`,toolbar:`shared`,tooltip:`panel`,zoom:`sync`,promote:!0,radiusByTotal:!1,targetTicks:3,panel:void 0},chart:{animations:{enabled:!0,speed:800,easing:`easeInOutSine`,animateGradually:{delay:150,enabled:!0},dynamicAnimation:{enabled:!0,speed:350,easing:void 0},chartTypeMorph:{enabled:!0,speed:600},respectReducedMotion:!0,largeDatasetThreshold:1e3},background:``,locales:[y],defaultLocale:`en`,perspectives:{serializeOptions:[`theme`,`xaxis`,`yaxis`,`title`,`subtitle`]},history:{enabled:!1,maxDepth:100,coalesceMs:250,keyboard:!0},renderer:`svg`,rendererThreshold:8e3,layers:{series:`auto`,grid:`svg`,annotations:`svg`,dataLabels:`svg`},dropShadow:{enabled:!1,enabledOnSeries:void 0,top:2,left:2,blur:4,color:`#000`,opacity:.7},events:{animationEnd:void 0,beforeMount:void 0,mounted:void 0,updated:void 0,click:void 0,mouseMove:void 0,mouseLeave:void 0,xAxisLabelClick:void 0,legendClick:void 0,markerClick:void 0,selection:void 0,dataPointSelection:void 0,dataPointMouseEnter:void 0,dataPointMouseLeave:void 0,beforeZoom:void 0,beforeResetZoom:void 0,zoomed:void 0,scrolled:void 0,brushScrolled:void 0,crossFilter:void 0,filterChange:void 0,annotationDragged:void 0,annotationEdited:void 0,annotationCreated:void 0,annotationStyled:void 0,annotationDeleted:void 0,measured:void 0,keyDown:void 0,keyUp:void 0},foreColor:`#373d3f`,fontFamily:`Helvetica, Arial, sans-serif`,height:`auto`,parentHeightOffset:15,redrawOnParentResize:!0,redrawOnWindowResize:!0,print:{enabled:!0,width:700},id:void 0,group:void 0,nonce:void 0,license:void 0,offsetX:0,offsetY:0,injectStyleSheet:!0,selection:{enabled:!1,type:`x`,fill:{color:`#24292e`,opacity:.1},stroke:{width:1,color:`#24292e`,opacity:.4,dashArray:3},xaxis:{min:void 0,max:void 0},yaxis:{min:void 0,max:void 0}},sparkline:{enabled:!1},brush:{enabled:!1,autoScaleYaxis:!0,target:void 0,targets:void 0},link:{enabled:!1,mode:`highlight`,dimOpacity:.2,id:void 0,dimension:void 0,reduce:void 0,type:void 0,bins:void 0,order:void 0,seriesName:void 0},ink:{enabled:!1,palette:!1,snap:!1,noteColors:void 0},measure:{enabled:!1,mode:`span`,key:`m`,pinOnRelease:!0,colors:{up:void 0,down:void 0,neutral:void 0,guide:void 0},band:!0,guides:!0,markers:!0,format:{x:void 0,y:void 0,percent:void 0},label:void 0},contextMenu:{enabled:!1,items:[`annotate`,`xline`,`yline`,`measure`],labels:{annotate:void 0,xline:void 0,yline:void 0,measure:void 0},noteText:`Note`,line:{text:``,strokeDashArray:4,color:void 0}},stacked:!1,stackOnlyBar:!0,stackType:`normal`,streaming:{enabled:!1,maxPoints:void 0},toolbar:{show:!0,offsetX:0,offsetY:0,tools:{download:!0,selection:!0,zoom:!0,zoomin:!0,zoomout:!0,pan:!0,reset:!0,measure:!0,customIcons:[]},export:{csv:{filename:void 0,columnDelimiter:`,`,headerCategory:`category`,headerValue:`value`,categoryFormatter:void 0,valueFormatter:void 0},png:{filename:void 0},svg:{filename:void 0},scale:void 0,width:void 0,embedFonts:!0},autoSelected:`zoom`},type:`line`,width:`100%`,zoom:{enabled:!0,type:`x`,autoScaleYaxis:!1,allowMouseWheelZoom:`auto`,pinch:`auto`,zoomedArea:{fill:{color:`#90CAF9`,opacity:.4},stroke:{color:`#0D47A1`,opacity:.4,width:1}}},pan:{inertia:!0,friction:.92},accessibility:{enabled:!0,description:void 0,announcements:{enabled:!0},keyboard:{enabled:!0,navigation:{enabled:!0,wrapAround:!1}}},dataReducer:{enabled:!1,algorithm:`lttb`,targetPoints:250,threshold:500}},parsing:{x:void 0,y:void 0},plotOptions:{line:{isSlopeChart:!1,colors:{threshold:0,colorAboveThreshold:void 0,colorBelowThreshold:void 0}},area:{fillTo:`origin`},bar:{horizontal:!1,columnWidth:`70%`,barHeight:`70%`,distributed:!1,borderRadius:0,borderRadiusApplication:`around`,rangeBarOverlap:!0,rangeBarGroupRows:!1,hideZeroBarsWhenGrouped:!1,isDumbbell:!1,dumbbellColors:void 0,dumbbell:{connector:{color:void 0,opacity:.55},dataLabels:{enabled:!1,offset:6,colorFromMarker:!0,formatter:void 0,style:{fontSize:`12px`,fontFamily:void 0,fontWeight:600,colors:void 0}},tooltip:{differenceLabel:`Difference`}},isFunnel:!1,isFunnel3d:!0,colors:{ranges:[],backgroundBarColors:[],backgroundBarOpacity:1,backgroundBarRadius:0},dataLabels:{position:`top`,maxItems:100,hideOverflowingLabels:!0,orientation:`horizontal`,total:{enabled:!1,formatter:void 0,offsetX:0,offsetY:0,style:{color:`#373d3f`,fontSize:`12px`,fontFamily:void 0,fontWeight:600}}}},bubble:{zScaling:!0,minBubbleRadius:void 0,maxBubbleRadius:void 0,minZ:void 0,maxZ:void 0},scatter:{jitter:{enabled:!1,x:0,y:0,distributed:!1,maxPoints:5e3}},candlestick:{colors:{upward:`#00B746`,downward:`#EF403C`},wick:{useFillColor:!0}},boxPlot:{colors:{upper:`#00E396`,lower:`#008FFB`},whiskers:`minmax`,points:{show:!1,shape:`circle`,size:2.5,jitter:.5,maxPoints:3e3,opacity:.9,fillColor:`series-dark`,strokeColor:`#fff`,strokeWidth:1}},violin:{bandwidthScale:1,kde:{bandwidth:void 0,resolution:64},normalize:`individual`,side:`both`,box:{show:!1,width:`15%`,whiskers:`minmax`,strokeWidth:1,fillColor:void 0,capWidth:.5},points:{show:!0,shape:`circle`,size:2.5,jitter:.5,constrainToViolin:!0,position:`center`,laneWidth:`40%`,maxPoints:3e3,opacity:.9,fillColor:`series-dark`,strokeColor:`#fff`,strokeWidth:1}},histogram:{bins:`auto`,binWidth:void 0,range:void 0,normalize:`count`,cumulative:!1,overlap:!0},heatmap:{shape:`rect`,radius:2,enableShades:!0,shadeIntensity:.5,reverseNegativeShade:!1,distributed:!1,useFillColorAsStroke:!1,colorScale:{inverse:!1,ranges:[],min:void 0,max:void 0,gradientLegend:{enabled:!1,width:`70%`,height:`70%`,thickness:12,align:`center`,stops:16,showLabels:!0,showHoverValue:!0,labelStyle:{fontSize:`11px`,fontFamily:void 0,colors:void 0},arrow:{size:8,color:void 0},formatter:void 0}}},waterfall:{colors:{positive:`#00A86F`,negative:`#FF4560`,subtotal:void 0,total:void 0},connectors:{show:!0,color:void 0,strokeWidth:1,strokeDashArray:3}},streamgraph:{offset:`wiggle`,order:`inside-out`,hover:{show:!0,opacity:.35},labels:{show:!0,minWidth:24,minFontSize:9,maxFontSize:30,style:{fontSize:`auto`,fontFamily:void 0,fontWeight:600,colors:void 0}}},funnel:{shape:`rectangle`,lastShape:`flat`},treemap:{enableShades:!0,shadeIntensity:.5,distributed:!1,reverseNegativeShade:!1,useFillColorAsStroke:!1,borderRadius:4,dataLabels:{format:`scale`,minFontSize:4},colorScale:{inverse:!1,ranges:[],min:void 0,max:void 0,colorValue:void 0,gradient:{enabled:void 0,min:void 0,max:void 0,midpoint:void 0,symmetric:!0,colors:void 0,stops:void 0},gradientLegend:{enabled:!1,width:`70%`,height:`70%`,thickness:12,align:`center`,stops:16,showLabels:!0,showHoverValue:!0,labelStyle:{fontSize:`11px`,fontFamily:void 0,colors:void 0},arrow:{size:8,color:void 0},formatter:void 0}},nested:{enabled:void 0,drilldownAsLevels:!1},parents:{show:`auto`,padding:4,fill:void 0,fillOpacity:1,borderColor:void 0,borderWidth:1,borderRadius:void 0,hover:{show:!0,color:void 0,width:2},header:{show:!0,height:22,minWidth:40,align:`left`,offsetX:0,offsetY:0,showValue:!1,formatter:void 0,style:{fontSize:`12px`,fontFamily:void 0,fontWeight:600,color:void 0,background:void 0,cssClass:``}},tooltip:{formatter:void 0}},levels:[],zoom:{enabled:!1,breadcrumb:void 0},seriesTitle:{show:!0,offsetY:1,offsetX:1,borderColor:`#000`,borderWidth:1,borderRadius:2,style:{background:`rgba(0, 0, 0, 0.6)`,color:`#fff`,fontSize:`12px`,fontFamily:void 0,fontWeight:400,cssClass:``,padding:{left:6,right:6,top:2,bottom:2}}}},unit:{layout:`grouped`,positions:void 0,transition:`group`,shape:`circle`,image:{src:void 0,width:20,height:20,tint:!1},pictogram:{mark:void 0,fit:`contain`,scale:1,padding:0,fallback:`circle`},size:`auto`,columns:{size:`inherit`},grid:{columns:10,total:void 0,fillFrom:`bottom`,split:!1,tileColumns:void 0,max:void 0,trackColor:void 0},scatter:{y:`lanes`,spread:`swarm`,orientation:`horizontal`,tickAmount:5,xMin:void 0,xMax:void 0,xTitle:void 0,xFormatter:void 0,yTickAmount:5,yMin:void 0,yMax:void 0,yTitle:void 0,yFormatter:void 0,sizeField:`z`,sizeRange:void 0,laneLabelWidth:void 0,gridlines:!0},sizeByValue:{enabled:!1,maxRadius:`auto`,minRadius:void 0,scale:`area`},spacing:1.05,borderRadius:0,gather:{motion:`auto`,spring:`crisp`,easing:`outCubic`,overshoot:1.70158,enter:`burst`},arc:{startAngle:-90,endAngle:90,innerRadiusRatio:.4,rows:`auto`},unitValue:1,maxUnits:5e3,sortByGroup:!0,clusterLabels:{show:!0,position:`top`,curved:!0,fontSize:`13px`,fontFamily:void 0,fontWeight:600,color:void 0,offsetY:0,formatter:void 0,external:{show:!1,connector:{show:!0,width:1.5,color:void 0,gap:8,length:22},offsetX:0,offsetY:0}},tooltip:{formatter:void 0}},radialBar:{inverseOrder:!1,startAngle:0,endAngle:360,offsetX:0,offsetY:0,shape:`arc`,min:0,max:100,bands:[],bandsStyle:{strokeWidth:`40%`,gap:0,hideTrackWhenPresent:!0},ticks:{show:!1,major:{count:11,length:10,width:2,color:`#666`,placement:`outside`},minor:{count:4,length:5,width:1,color:`#999`,placement:`outside`},labels:{show:!1,offset:6,fontSize:`11px`,fontFamily:void 0,fontWeight:400,color:`#666`,formatter(e){return String(e)}}},needle:{color:`#333`,length:`85%`,baseWidth:4,tipWidth:1,offsetY:0,showValueArc:!1,animation:{enabled:!0,duration:800,easing:`ease-out`}},hollow:{margin:5,size:`50%`,background:`transparent`,image:void 0,imageWidth:150,imageHeight:150,imageOffsetX:0,imageOffsetY:0,imageClipped:!0,position:`front`,stroke:void 0,strokeWidth:1,strokeDasharray:void 0,dropShadow:{enabled:!1,top:0,left:0,blur:3,color:`#000`,opacity:.5}},track:{show:!0,startAngle:void 0,endAngle:void 0,background:`#f2f2f2`,strokeWidth:`97%`,opacity:1,margin:5,dropShadow:{enabled:!1,top:0,left:0,blur:3,color:`#000`,opacity:.5}},dataLabels:{show:!0,name:{show:!0,fontSize:`16px`,fontFamily:void 0,fontWeight:600,color:void 0,offsetY:0,formatter(e){return e}},value:{show:!0,fontSize:`14px`,fontFamily:void 0,fontWeight:400,color:void 0,offsetY:16,formatter(e){return e+`%`}},total:{show:!1,label:`Total`,fontSize:`16px`,fontWeight:600,fontFamily:void 0,color:void 0,formatter(e){return e.globals.seriesTotals.reduce((e,t)=>e+t,0)/e.seriesData.series.length+`%`}}},barLabels:{enabled:!1,offsetX:0,offsetY:0,useSeriesColors:!0,fontFamily:void 0,fontWeight:600,fontSize:`16px`,formatter(e){return e},onClick:void 0}},pie:{customScale:1,offsetX:0,offsetY:0,startAngle:0,endAngle:360,expandOnClick:!0,expandOffset:10,hoverOutline:{show:!0,size:8,gap:0,opacity:.3,color:void 0},borderRadius:0,spacing:0,dataLabels:{offset:0,minAngleToShowLabel:10,external:{show:!1,offsetX:0,offsetY:0,fontSize:void 0,fontFamily:void 0,fontWeight:void 0,color:void 0,formatter:void 0,connector:{show:!0,width:1,color:void 0,length:16,gap:6}}},donut:{size:`65%`,background:`transparent`,labels:{show:!1,name:{show:!0,fontSize:`16px`,fontFamily:void 0,fontWeight:600,color:void 0,offsetY:-10,formatter(e){return e}},value:{show:!0,fontSize:`20px`,fontFamily:void 0,fontWeight:400,color:void 0,offsetY:10,formatter(e){return e}},total:{show:!1,showAlways:!1,label:`Total`,fontSize:`16px`,fontWeight:400,fontFamily:void 0,color:void 0,formatter(e){return e.globals.seriesTotals.reduce((e,t)=>e+t,0)}}}}},polarArea:{rings:{strokeWidth:1,strokeColor:`#e8e8e8`},spokes:{strokeWidth:1,connectorColors:`#e8e8e8`}},sunburst:{offsetX:0,offsetY:0,startAngle:0,endAngle:360,innerSize:`15%`,borderRadius:0,spacing:1,leaf:`extend`,partition:`normalize`,tint:.14,zoomOnClick:!0,dataLabels:{show:!0,minAngleToShow:8,style:{fontSize:`12px`,fontFamily:void 0,fontWeight:400,colors:void 0}}},radar:{size:void 0,offsetX:0,offsetY:0,polygons:{strokeWidth:1,strokeColors:`#e8e8e8`,connectorColors:`#e8e8e8`,fill:{colors:void 0}}}},colors:void 0,dataLabels:{enabled:!0,enabledOnSeries:void 0,formatter(e){return e===null?``:e},textAnchor:`middle`,distributed:!1,offsetX:0,offsetY:0,style:{fontSize:`12px`,fontFamily:void 0,fontWeight:600,colors:void 0},background:{enabled:!0,foreColor:`#fff`,backgroundColor:void 0,borderRadius:2,padding:4,opacity:.9,borderWidth:1,borderColor:`#fff`,dropShadow:{enabled:!1,top:1,left:1,blur:1,color:`#000`,opacity:.8}},dropShadow:{enabled:!1,top:1,left:1,blur:1,color:`#000`,opacity:.8},animate:{enabled:!0},countUp:{enabled:!1}},fill:{type:`solid`,colors:void 0,opacity:.85,gradient:{shade:`dark`,type:`horizontal`,shadeIntensity:.5,gradientToColors:void 0,inverseColors:!0,opacityFrom:1,opacityTo:1,stops:[0,50,100],colorStops:[]},image:{src:[],width:void 0,height:void 0},pattern:{style:`squares`,width:6,height:6,strokeWidth:2}},forecastDataPoints:{count:0,fillOpacity:.5,strokeWidth:void 0,dashArray:4},grid:{show:!0,borderColor:`#e0e0e0`,strokeDashArray:0,position:`back`,xaxis:{lines:{show:!1}},yaxis:{lines:{show:!0}},row:{colors:void 0,opacity:.5},column:{colors:void 0,opacity:.5},padding:{top:0,right:10,bottom:0,left:12}},labels:[],drilldown:{enabled:!1,series:[],breadcrumb:{show:!0,position:`top-left`,separator:` / `,rootLabel:`All`,offsetX:0,offsetY:0},animation:{enabled:!0,zoomFromPoint:!1,speed:260},loading:{show:!0},cache:!0,marker:{show:!0,size:6,strokeColor:`#fff`}},legend:{show:!0,showForSingleSeries:!1,showForNullSeries:!0,showForZeroSeries:!0,floating:!1,position:`bottom`,horizontalAlign:`center`,inverseOrder:!1,fontSize:`12px`,fontFamily:void 0,fontWeight:400,width:void 0,height:void 0,formatter:void 0,tooltipHoverFormatter:void 0,offsetX:-20,offsetY:4,customLegendItems:[],clusterGroupedSeries:!0,clusterGroupedSeriesOrientation:`vertical`,labels:{colors:void 0,useSeriesColors:!1},markers:{size:7,fillColors:void 0,strokeWidth:1,shape:void 0,offsetX:0,offsetY:0,customHTML:void 0,onClick:void 0},itemMargin:{horizontal:5,vertical:4},onItemClick:{toggleDataSeries:!0},onItemHover:{highlightDataSeries:!0}},markers:{discrete:[],size:0,colors:void 0,strokeColors:`#fff`,strokeWidth:2,strokeOpacity:.9,strokeDashArray:0,fillOpacity:1,shape:`circle`,offsetX:0,offsetY:0,showNullDataPoints:!0,onClick:void 0,onDblClick:void 0,hover:{size:void 0,sizeOffset:3},largeDatasetThreshold:0},noData:{text:void 0,align:`center`,offsetX:0,offsetY:0,style:{color:void 0,fontSize:`14px`,fontFamily:void 0}},responsive:[],series:void 0,states:{hover:{filter:{type:`lighten`,value:.15}},active:{allowMultipleDataPointsSelection:!1,filter:{type:`darken`,value:.35}}},title:{text:void 0,align:`left`,margin:5,offsetX:0,offsetY:0,floating:!1,style:{fontSize:`14px`,fontWeight:900,fontFamily:void 0,color:void 0}},subtitle:{text:void 0,align:`left`,margin:5,offsetX:0,offsetY:30,floating:!1,style:{fontSize:`12px`,fontWeight:400,fontFamily:void 0,color:void 0}},stroke:{show:!0,curve:`smooth`,lineCap:`butt`,width:2,colors:void 0,dashArray:0,fill:{type:`solid`,colors:void 0,opacity:.85,gradient:{shade:`dark`,type:`horizontal`,shadeIntensity:.5,gradientToColors:void 0,inverseColors:!0,opacityFrom:1,opacityTo:1,stops:[0,50,100],colorStops:[]}}},tooltip:{enabled:!0,enabledOnSeries:void 0,shared:!0,hideEmptySeries:!1,followCursor:!1,intersect:!1,inverseOrder:!1,arrow:!0,compact:!1,custom:void 0,fillSeriesColor:!1,theme:`light`,cssClass:``,style:{fontSize:`12px`,fontFamily:void 0,background:void 0},onDatasetHover:{highlightDataSeries:!1},x:{show:!0,format:`dd MMM`,formatter:void 0},y:{formatter:void 0,title:{formatter(e){return e?e+`: `:``}}},z:{formatter:void 0,title:`Size: `},marker:{show:!0,fillColors:void 0},items:{display:`flex`},fixed:{enabled:!1,position:`topRight`,offsetX:0,offsetY:0}},xaxis:{type:`category`,categories:[],convertedCatToNumeric:!1,offsetX:0,offsetY:0,overwriteCategories:void 0,labels:{show:!0,rotate:-45,rotateAlways:!1,hideOverlappingLabels:!0,trim:!1,minHeight:void 0,maxHeight:120,showDuplicates:!0,style:{colors:[],fontSize:`12px`,fontWeight:400,fontFamily:void 0,cssClass:``},offsetX:0,offsetY:0,format:void 0,formatter:void 0,datetimeUTC:!0,datetimeFormatter:{year:`yyyy`,month:`MMM`,day:`dd MMM`,hour:`HH:mm`,minute:`HH:mm`,second:`HH:mm:ss`}},group:{groups:[],style:{colors:[],fontSize:`12px`,fontWeight:400,fontFamily:void 0,cssClass:``}},axisBorder:{show:!0,color:`#e0e0e0`,width:`100%`,height:1,offsetX:0,offsetY:0},axisTicks:{show:!0,color:`#e0e0e0`,height:6,offsetX:0,offsetY:0},stepSize:void 0,tickAmount:void 0,tickPlacement:`on`,min:void 0,max:void 0,range:void 0,floating:!1,decimalsInFloat:void 0,position:`bottom`,title:{text:void 0,offsetX:0,offsetY:0,style:{color:void 0,fontSize:`12px`,fontWeight:900,fontFamily:void 0,cssClass:``}},crosshairs:{show:!0,width:1,position:`back`,opacity:.9,stroke:{color:`#b6b6b6`,width:1,dashArray:3},fill:{type:`solid`,color:`#B1B9C4`,gradient:{colorFrom:`#D8E3F0`,colorTo:`#BED1E6`,stops:[0,100],opacityFrom:.4,opacityTo:.5}},dropShadow:{enabled:!1,left:0,top:0,blur:1,opacity:.8}},tooltip:{enabled:!1,offsetY:0,formatter:void 0,style:{fontSize:`12px`,fontFamily:void 0}}},yaxis:this.yAxis,theme:{mode:``,palette:`palette1`,tokens:!0,follow:!1,name:``,monochrome:{enabled:!1,color:`#008FFB`,shadeTo:`light`,shadeIntensity:.65},accessibility:{colorBlindMode:``}}}}}const b={funnel:`bar`,pyramid:`bar`,gauge:`radialBar`,waffle:`unit`,histogram:`bar`,waterfall:`rangeBar`,dumbbell:`rangeBar`,streamgraph:`rangeArea`,raincloud:`violin`},x=`_apexOwnedByType`,S=(e,t)=>{let n=t;return n[x]=e,t},C=[`tooltip.custom`,`tooltip.shared`,`tooltip.intersect`,`tooltip.followCursor`,`dataLabels.enabled`,`dataLabels.formatter`,`plotOptions.bar.dataLabels.position`,`markers.size`,`plotOptions.violin.side`,`plotOptions.violin.box.show`,`plotOptions.violin.box.whiskers`,`plotOptions.violin.points.position`,`states.hover.filter.type`,`states.active.filter.type`,`xaxis.crosshairs.width`,`xaxis.tickPlacement`,`xaxis.tooltip.enabled`,`chart.zoom.enabled`,`chart.animations.dynamicAnimation.enabled`],w=(e,t)=>{let n=e;for(let e of t.split(`.`)){if(typeof n!=`object`||!n)return;n=n[e]}return n},T=(e,t,n)=>{let r=t.split(`.`),i=r.pop(),a=e;for(let e of r)(a[e]==null||typeof a[e]!=`object`)&&(a[e]={}),a=a[e];n===void 0?delete a[i]:a[i]=n},E=(e,t)=>{var n,r;let i=b[e];return{chart:{type:i||e,requestedType:i?e:void 0,stacked:(n=t.chart)==null?void 0:n.stacked},plotOptions:{bar:{isFunnel:e===`funnel`||e===`pyramid`},histogram:(r=t.plotOptions)==null?void 0:r.histogram},series:t.series,yaxis:[{title:{},labels:{},axisBorder:{},axisTicks:{}}]}},D=(e,t)=>{if(typeof e==`function`)return Array.isArray(e[x])?!0:typeof t==`function`&&String(e)===String(t);if(typeof t==`function`)return e===void 0;if(e===t)return!0;try{return JSON.stringify(e)===JSON.stringify(t)}catch(e){return!1}},O=({isTimeline:e,seriesIndex:t,dataPointIndex:n,y1:r,y2:i,w:a})=>{var o;let s=a.rangeData.seriesRangeStart[t][n],c=a.rangeData.seriesRangeEnd[t][n],u=a.labelData.labels[n],d=a.config.series[t].name?a.config.series[t].name:``,f=a.formatters.ttKeyFormatter,p=a.config.tooltip.y.title.formatter,m={w:a,seriesIndex:t,dataPointIndex:n,start:s,end:c};typeof p==`function`&&(d=p(d,m)),(o=a.config.series[t].data[n])!=null&&o.x&&(u=a.config.series[t].data[n].x),e||a.config.xaxis.type===`datetime`&&(u=new Formatters(a).xLabelFormat(a.formatters.ttKeyFormatter,u,u,{i:void 0,dateFormatter:new DateTime(a).formatDate,w:a})),typeof f==`function`&&(u=f(u,m)),Number.isFinite(r)&&Number.isFinite(i)&&(s=r,c=i);let h=``,g=``,_=a.globals.colors[t];if(a.config.tooltip.x.formatter===void 0)if(a.config.xaxis.type===`datetime`){let e=new DateTime(a);h=e.formatDate(e.getDate(s),a.config.tooltip.x.format),g=e.formatDate(e.getDate(c),a.config.tooltip.x.format)}else h=s,g=c;else h=a.config.tooltip.x.formatter(s),g=a.config.tooltip.x.formatter(c);return{start:s,end:c,startVal:h,endVal:g,ylabel:u,color:_,seriesName:d}},k=e=>{let{color:t,seriesName:n,ylabel:r,start:i,end:a,seriesIndex:o,dataPointIndex:s}=e,c=e.w.globals.tooltip.tooltipLabels.getFormatters(o);i=c.yLbFormatter(i),a=c.yLbFormatter(a);let u=c.yLbFormatter(e.w.seriesData.series[o][s]),d=``,f=`<span class="value start-value">
  ${i}
  </span> <span class="separator">-</span> <span class="value end-value">
  ${a}
  </span>`;return d=e.w.globals.comboCharts?e.w.config.series[o].type===`rangeArea`||e.w.config.series[o].type===`rangeBar`?f:`<span>${u}</span>`:f,`<div class="apexcharts-tooltip-rangebar"><div> <span class="series-name" style="color: `+t+`">`+(n||``)+`</span></div><div> <span class="category">`+r+`: </span> `+d+` </div></div>`};class Defaults{constructor(e){this.opts=e}static forType(e){var t,n;let r=new Defaults(e),i=[`line`,`area`,`bar`,`candlestick`,`boxPlot`,`violin`,`rangeBar`,`rangeArea`,`bubble`,`scatter`,`heatmap`,`treemap`,`unit`,`sunburst`,`pie`,`polarArea`,`donut`,`radar`,`radialBar`],a=e.chart.requestedType,o;return o=a===`funnel`||a===`pyramid`?r[a]():a===`gauge`?r.gauge():a===`histogram`?r.histogram():a===`waterfall`?r.waterfall():a===`dumbbell`?r.dumbbell():a===`streamgraph`?r.streamgraph():a===`raincloud`?r.raincloud():i.indexOf(e.chart.type)===-1?r.line():r[e.chart.type](),(n=(t=e.plotOptions)==null?void 0:t.bar)!=null&&n.isFunnel&&(o=r.funnel()),e.chart.stacked&&e.chart.type===`bar`&&(o=r.stackedBars()),o}static handOverTypeDefaults(e,t,n){let r=e.chart.requestedType||e.chart.type;if(!t||t===r)return;let i=new Options().init(),a=_.extend(i,Defaults.forType(E(t,e))),o=_.extend(i,Defaults.forType(E(r,e)));for(let t of C){if(n&&w(n,t)!==void 0)continue;let r=w(a,t),i=w(o,t);r===void 0&&i===void 0||D(w(e,t),r)&&T(e,t,i)}}hideYAxis(){this.opts.yaxis[0].show=!1,this.opts.yaxis[0].title.text=``,this.opts.yaxis[0].axisBorder.show=!1,this.opts.yaxis[0].axisTicks.show=!1,this.opts.yaxis[0].floating=!0}line(){return{dataLabels:{enabled:!1},stroke:{width:5,curve:`straight`},markers:{size:0,hover:{sizeOffset:6}},xaxis:{crosshairs:{width:1}}}}sparkline(e){return this.hideYAxis(),_.extend(e,{grid:{show:!1,padding:{left:0,right:0,top:0,bottom:0}},legend:{show:!1},xaxis:{labels:{show:!1},tooltip:{enabled:!1},axisBorder:{show:!1},axisTicks:{show:!1}},chart:{toolbar:{show:!1},zoom:{enabled:!1}},dataLabels:{enabled:!1}})}slope(){return this.hideYAxis(),{chart:{toolbar:{show:!1},zoom:{enabled:!1}},dataLabels:{enabled:!0,formatter(e,t){let n=t.w.config.series[t.seriesIndex].name;return e===null?``:n+`: `+e},background:{enabled:!1},offsetX:-5},grid:{xaxis:{lines:{show:!0}},yaxis:{lines:{show:!1}}},xaxis:{position:`top`,labels:{style:{fontSize:14,fontWeight:900}},tooltip:{enabled:!1},crosshairs:{show:!1}},markers:{size:8,hover:{sizeOffset:1}},legend:{show:!1},tooltip:{shared:!1,intersect:!0,followCursor:!0},stroke:{width:5,curve:`straight`}}}bar(){return{chart:{stacked:!1},plotOptions:{bar:{dataLabels:{position:`center`}}},dataLabels:{style:{colors:[`#fff`]},background:{enabled:!1}},stroke:{width:0,lineCap:`square`},fill:{opacity:.85},legend:{markers:{shape:`square`}},tooltip:{shared:!1,intersect:!0},xaxis:{tooltip:{enabled:!1},tickPlacement:`between`,crosshairs:{width:`barWidth`,position:`back`,fill:{type:`gradient`},dropShadow:{enabled:!1},stroke:{width:0}}}}}funnel(){return this.hideYAxis(),c(s({},this.bar()),{chart:{animations:{speed:800,animateGradually:{enabled:!1}}},plotOptions:{bar:{horizontal:!0,borderRadiusApplication:`around`,borderRadius:0,dataLabels:{position:`center`}}},grid:{show:!1,padding:{left:0,right:0}},xaxis:{labels:{show:!1},tooltip:{enabled:!1},axisBorder:{show:!1},axisTicks:{show:!1}}})}pyramid(){return this.funnel()}gauge(){return c(s({},this.radialBar()),{plotOptions:{radialBar:{startAngle:-135,endAngle:135,hollow:{margin:0,size:`60%`},track:{background:`#e7e7e7`,strokeWidth:`100%`,margin:5},dataLabels:{name:{show:!1},value:{show:!0,fontSize:`32px`,fontWeight:600,offsetY:8}}}}})}waterfall(){let e=this.rangeBar();return c(s({},e),{chart:{stacked:!1,zoom:{enabled:!1},animations:{animateGradually:{enabled:!0}}},plotOptions:c(s({},e.plotOptions),{bar:c(s({},e.plotOptions.bar),{columnWidth:`60%`,barHeight:`60%`})}),dataLabels:c(s({},e.dataLabels),{enabled:!0,background:{enabled:!0,backgroundColor:`#fff`,foreColor:`#373d3f`,borderColor:`#e3e8ee`,opacity:.92}}),legend:{show:!1},tooltip:{shared:!1,intersect:!0,followCursor:!1}})}histogram(){var e,t,n,r;let i=Array.isArray((e=this.opts)==null?void 0:e.series)&&this.opts.series.length>1&&((r=(n=(t=this.opts)==null?void 0:t.plotOptions)==null?void 0:n.histogram)==null?void 0:r.overlap)!==!1;return c(s({},this.bar()),{chart:{stacked:!1,zoom:{enabled:!1},animations:{animateGradually:{enabled:!1}}},plotOptions:{bar:{columnWidth:`100%`,borderRadius:0,dataLabels:{position:`top`}}},dataLabels:{enabled:!1},fill:i?{opacity:.65}:{},stroke:i?{show:!1}:{show:!0,width:1,colors:[`#fff`]},xaxis:{type:`numeric`,tooltip:{enabled:!1}},tooltip:{shared:i,intersect:!1,x:{formatter:(e,t)=>{var n,r;let i=(r=(n=t==null?void 0:t.w)==null?void 0:n.histogramData)==null?void 0:r.edges,a=t==null?void 0:t.dataPointIndex;if(!Array.isArray(i)||typeof a!=`number`||a<0)return String(e);let o=i[a],s=i[a+1];if(o===void 0||s===void 0)return String(e);let c=e=>Number.isInteger(e)?String(e):e.toFixed(2);return`${c(o)} to ${c(s)}`}}}})}candlestick(){return{stroke:{width:1},fill:{opacity:1},dataLabels:{enabled:!1},tooltip:{shared:!0,custom:S([`candlestick`],({seriesIndex:e,dataPointIndex:t,w:n})=>this._getBoxTooltip(n,e,t,[`Open`,`High`,``,`Low`,`Close`],`candlestick`))},states:{active:{filter:{type:`none`}}},xaxis:{crosshairs:{width:1}}}}boxPlot(){return{chart:{animations:{dynamicAnimation:{enabled:!1}}},stroke:{width:1,colors:[`#24292e`]},dataLabels:{enabled:!1},tooltip:{shared:!0,custom:S([`boxPlot`],({seriesIndex:e,dataPointIndex:t,w:n})=>this._getBoxTooltip(n,e,t,[`Minimum`,`Q1`,`Median`,`Q3`,`Maximum`],`boxPlot`))},markers:{size:7,strokeWidth:1,strokeColors:`#111`},xaxis:{crosshairs:{width:1}}}}violin(){return{chart:{zoom:{enabled:!1},animations:{dynamicAnimation:{enabled:!1}}},stroke:{width:1,colors:[`#24292e`]},fill:{opacity:.7},dataLabels:{enabled:!1},tooltip:{shared:!0,custom:S([`violin`],({seriesIndex:e,dataPointIndex:t,w:n})=>this._getViolinTooltip(n,e,t))},states:{active:{filter:{type:`none`}}},xaxis:{crosshairs:{width:1}}}}raincloud(){var e,t,n;let r=this.violin(),i=((n=(t=(e=this.opts)==null?void 0:e.plotOptions)==null?void 0:t.bar)==null?void 0:n.horizontal)===!0;return c(s({},r),{plotOptions:{violin:{side:i?`top`:`right`,box:{show:!0,whiskers:`tukey`},points:{position:i?`bottom`:`left`,jitter:.85}}},tooltip:c(s({},r.tooltip),{custom:S([`raincloud`],({seriesIndex:e,dataPointIndex:t,w:n})=>this._getRaincloudTooltip(n,e,t))})})}rangeBar(){let e=e=>{let{color:t,seriesName:n,ylabel:r,startVal:i,endVal:a}=O(c(s({},e),{isTimeline:!0}));return k(c(s({},e),{color:t,seriesName:n,ylabel:r,start:i,end:a}))},t=e=>{let{color:t,seriesName:n,ylabel:r,start:i,end:a}=O(e);return k(c(s({},e),{color:t,seriesName:n,ylabel:r,start:i,end:a}))};return{chart:{animations:{animateGradually:!1}},stroke:{width:0,lineCap:`square`},plotOptions:{bar:{borderRadius:0,dataLabels:{position:`center`}}},dataLabels:{enabled:!1,formatter(e,{seriesIndex:t,dataPointIndex:n,w:r}){let i=()=>{let e=r.rangeData.seriesRangeStart[t][n];return r.rangeData.seriesRangeEnd[t][n]-e};return r.globals.comboCharts?r.config.series[t].type===`rangeBar`||r.config.series[t].type===`rangeArea`?i():e:i()},background:{enabled:!1},style:{colors:[`#fff`]}},markers:{size:10},tooltip:{shared:!1,followCursor:!0,custom:S([`rangeBar`],n=>n.w.config.plotOptions&&n.w.config.plotOptions.bar&&n.w.config.plotOptions.bar.horizontal?e(n):t(n))},xaxis:{tickPlacement:`between`,tooltip:{enabled:!1},crosshairs:{stroke:{width:0}}}}}dumbbell(){let e=this.rangeBar(),t=(e,t,n)=>`<div class="apexcharts-tooltip-dumbbell-endpoint"><span class="series-name" style="color: `+t+`">`+e+`</span> <span class="value">`+n+`</span></div>`,n=e=>{var n;let{w:r,dataPointIndex:i,seriesIndex:a}=e,o=r.dumbbellData;if(!o||o.form!==`series`){let{color:t,seriesName:n,ylabel:r,start:i,end:a}=O(e);return k(c(s({},e),{color:t,seriesName:n,ylabel:r,start:i,end:a}))}let u=o.values[i]||[],d=r.globals.tooltip.tooltipLabels.getFormatters(a),f=(n=r.labelData.labels[i])==null?``:n,p=``,m=[];for(let e=0;e<u.length;e++)u[e]===null||o.hidden.indexOf(e)!==-1||(m.push(u[e]),p+=t(o.names[e],r.globals.colors[e],d.yLbFormatter(u[e])));let h=m.length===2?`<div class="apexcharts-tooltip-dumbbell-gap"><span class="category">`+r.config.plotOptions.bar.dumbbell.tooltip.differenceLabel+`: </span><span class="value">`+d.yLbFormatter(Math.abs(m[1]-m[0]))+`</span></div>`:``;return`<div class="apexcharts-tooltip-rangebar apexcharts-tooltip-dumbbell"><div><span class="category">`+f+`</span></div>`+p+h+`</div>`};return c(s({},e),{chart:{stacked:!1,zoom:{enabled:!1}},plotOptions:c(s({},e.plotOptions),{bar:c(s({},e.plotOptions.bar),{barHeight:6,columnWidth:6,dumbbell:{dataLabels:{enabled:!0}}})}),dataLabels:c(s({},e.dataLabels),{enabled:!1}),legend:{show:!0,position:`bottom`,horizontalAlign:`left`,markers:{shape:`circle`}},tooltip:{shared:!1,intersect:!0,followCursor:!1,custom:S([`rangeBar`],n)}})}dumbbellSizing(e){var t,n;return(t=e.plotOptions.bar)!=null&&t.barHeight||(e.plotOptions.bar.barHeight=2),(n=e.plotOptions.bar)!=null&&n.columnWidth||(e.plotOptions.bar.columnWidth=2),e}area(){return{stroke:{width:4,fill:{type:`solid`,gradient:{inverseColors:!1,shade:`light`,type:`vertical`,opacityFrom:.65,opacityTo:.5,stops:[0,100,100]}}},fill:{type:`gradient`,gradient:{inverseColors:!1,shade:`light`,type:`vertical`,opacityFrom:.65,opacityTo:.5,stops:[0,100,100]}},markers:{size:0,hover:{sizeOffset:6}},tooltip:{followCursor:!1}}}rangeArea(){let e=e=>{let{color:t,seriesName:n,ylabel:r,start:i,end:a}=O(e);return k(c(s({},e),{color:t,seriesName:n,ylabel:r,start:i,end:a}))};return{stroke:{curve:`straight`,width:0},fill:{type:`solid`,opacity:.6},markers:{size:0},states:{hover:{filter:{type:`none`}},active:{filter:{type:`none`}}},tooltip:{intersect:!1,shared:!0,followCursor:!0,custom:S([`rangeArea`],t=>e(t))}}}streamgraph(){let e=this.rangeArea(),t=e=>{var t;let{w:n,dataPointIndex:r,seriesIndex:i}=e,a=n.streamgraphData;if(!a||!Array.isArray(a.order)){let{color:t,seriesName:n,ylabel:r,start:i,end:a}=O(e);return k(c(s({},e),{color:t,seriesName:n,ylabel:r,start:i,end:a}))}let{ylabel:o}=O(e),u=(()=>{let e=n.streamgraphData,t=n.dom.baseEl&&n.dom.baseEl.querySelector(`.apexcharts-svg`),a=n.interact&&n.interact.clientY,o=n.globals.maxY-n.globals.minY;if(!t||a==null||!o||!isFinite(o))return i;let s=t.getBoundingClientRect(),c=n.globals.svgWidth?s.width/n.globals.svgWidth:1,u=(a-s.top)/(c||1)-n.layout.translateY,d=n.layout.gridHeight,f=e=>{var t;let r=(e-n.globals.minY)/o;return(t=n.config.yaxis[0])!=null&&t.reversed?r*d:d-r*d},p=i,m=1/0;for(let t=0;t<e.order.length;t++){let n=e.order[t],i=e.lows[n]&&e.lows[n][r],a=e.highs[n]&&e.highs[n][r];if(i==null||a==null)continue;let o=f(a),s=f(i),c=Math.min(o,s),d=Math.max(o,s);if(u>=c&&u<=d)return n;let h=u<c?c-u:u-d;h<m&&(m=h,p=n)}return p})(),d=n.formatters.ttVal!==void 0,f=(e,t)=>{if(d){let r=n.globals.tooltip.tooltipLabels.getFormatters(e);if(typeof r.yLbFormatter==`function`)return r.yLbFormatter(t)}return String(Number.isInteger(t)?t:Number(t.toFixed(6)))},p=``,m=0;for(let e=a.order.length-1;e>=0;e--){let i=a.order[e],o=(t=a.values[i])==null?void 0:t[r];o==null||!isFinite(o)||(m+=o,p+=`<div class="apexcharts-tooltip-stream-band`+(i===u?` apexcharts-active`:``)+`"><span class="apexcharts-tooltip-marker" style="background-color: `+n.globals.colors[i]+`"></span><span class="series-name">`+a.names[i]+`</span> <span class="value">`+f(i,o)+`</span></div>`)}let h=a.offset===`expand`?``:`<div class="apexcharts-tooltip-stream-total"><span class="series-name">Total</span> <span class="value">`+f(i,m)+`</span></div>`;return`<div class="apexcharts-tooltip-stream"><div class="apexcharts-tooltip-title">`+o+`</div>`+p+h+`</div>`};return c(s({},e),{chart:{stacked:!1},stroke:{curve:`monotoneCubic`,width:0},fill:{type:`solid`,opacity:1},dataLabels:{enabled:!1},grid:{yaxis:{lines:{show:!1}}},markers:{size:0,hover:{size:0,sizeOffset:0}},tooltip:{intersect:!1,shared:!1,followCursor:!0,custom:S([`streamgraph`],e=>t(e))},legend:{show:!0,position:`top`,horizontalAlign:`center`}})}brush(e){return _.extend(e,{chart:{toolbar:{autoSelected:`selection`,show:!1},zoom:{enabled:!1}},dataLabels:{enabled:!1},stroke:{width:1},tooltip:{enabled:!1},xaxis:{tooltip:{enabled:!1}}})}stacked100(e){e.dataLabels=e.dataLabels||{},e.dataLabels.formatter=e.dataLabels.formatter||void 0;let t=e.dataLabels.formatter;return e.yaxis.forEach((t,n)=>{e.yaxis[n].min=0,e.yaxis[n].max=100}),e.chart.type===`bar`&&(e.dataLabels.formatter=t||function(e){return typeof e==`number`?e&&e.toFixed(0)+`%`:e}),e}stackedBars(){let e=this.bar();return c(s({},e),{plotOptions:c(s({},e.plotOptions),{bar:c(s({},e.plotOptions.bar),{borderRadiusApplication:`end`})})})}convertCatToNumeric(e){return e.xaxis.convertedCatToNumeric=!0,e}convertCatToNumericXaxis(e,t){e.xaxis.type=`numeric`,e.xaxis.labels=e.xaxis.labels||{},e.xaxis.labels.formatter=e.xaxis.labels.formatter||function(e){return _.isNumber(e)?Math.floor(e):e};let n=e.xaxis.labels.formatter,r=e.xaxis.categories&&e.xaxis.categories.length?e.xaxis.categories:e.labels;return t&&t.length&&(r=t.map(e=>Array.isArray(e)?e:String(e))),r&&r.length&&(e.xaxis.labels.formatter=function(e){return _.isNumber(e)?n(r[Math.floor(e)-1]):n(e)}),e.xaxis.categories=[],e.labels=[],e.xaxis.tickAmount=e.xaxis.tickAmount||`dataPoints`,e}bubble(){return{dataLabels:{style:{colors:[`#fff`]}},tooltip:{shared:!1,intersect:!0},xaxis:{crosshairs:{width:0}},fill:{type:`solid`,gradient:{shade:`light`,inverse:!0,shadeIntensity:.55,opacityFrom:.4,opacityTo:.8}}}}scatter(){return{dataLabels:{enabled:!1},tooltip:{shared:!1,intersect:!0},markers:{size:6,strokeWidth:1,hover:{sizeOffset:2}}}}heatmap(){return{chart:{stacked:!1,zoom:{enabled:!1}},fill:{opacity:1},dataLabels:{style:{colors:[`#fff`]}},stroke:{colors:[`#fff`]},tooltip:{followCursor:!1,marker:{show:!1},x:{show:!1}},legend:{position:`top`,markers:{shape:`square`}},grid:{padding:{right:20}}}}treemap(){return{chart:{zoom:{enabled:!1}},dataLabels:{style:{fontSize:14,fontWeight:600,colors:[`#fff`]}},stroke:{show:!0,width:2,colors:[`#fff`]},legend:{show:!1},fill:{opacity:1,gradient:{stops:[0,100]}},tooltip:{followCursor:!0,x:{show:!1}},grid:{padding:{left:0,right:0}},xaxis:{crosshairs:{show:!1},tooltip:{enabled:!1},axisTicks:{show:!1}}}}unit(){return{chart:{toolbar:{show:!1}},dataLabels:{enabled:!1},stroke:{show:!1,width:0},fill:{opacity:1},tooltip:{followCursor:!0,x:{show:!1}},legend:{show:!0,position:`bottom`},grid:{padding:{left:0,right:0,top:0,bottom:0}}}}sunburst(){return{chart:{toolbar:{show:!1}},dataLabels:{style:{colors:[`#fff`]},dropShadow:{enabled:!0}},stroke:{colors:[`#fff`]},fill:{opacity:1},legend:{position:`right`},grid:{padding:{left:0,right:0,top:0,bottom:0}}}}pie(){return{chart:{toolbar:{show:!1}},plotOptions:{pie:{donut:{labels:{show:!1}}}},dataLabels:{formatter(e){return typeof e==`number`?e.toFixed(1)+`%`:e},style:{colors:[`#fff`]},background:{enabled:!1},dropShadow:{enabled:!0}},stroke:{colors:[`#fff`]},fill:{opacity:1,gradient:{shade:`light`,stops:[0,100]}},tooltip:{theme:`dark`,fillSeriesColor:!0},legend:{position:`right`},grid:{padding:{left:0,right:0,top:0,bottom:0}}}}donut(){return{chart:{toolbar:{show:!1}},dataLabels:{formatter(e){return typeof e==`number`?e.toFixed(1)+`%`:e},style:{colors:[`#fff`]},background:{enabled:!1},dropShadow:{enabled:!0}},stroke:{colors:[`#fff`]},fill:{opacity:1,gradient:{shade:`light`,shadeIntensity:.35,stops:[80,100],opacityFrom:1,opacityTo:1}},tooltip:{theme:`dark`,fillSeriesColor:!0},legend:{position:`right`},grid:{padding:{left:0,right:0,top:0,bottom:0}}}}polarArea(){return{chart:{toolbar:{show:!1}},dataLabels:{formatter(e){return typeof e==`number`?e.toFixed(1)+`%`:e},enabled:!1},stroke:{show:!0,width:2},fill:{opacity:.7},tooltip:{theme:`dark`,fillSeriesColor:!0},legend:{position:`right`},grid:{padding:{left:0,right:0,top:0,bottom:0}}}}radar(){return this.opts.yaxis[0].labels.offsetY=this.opts.yaxis[0].labels.offsetY?this.opts.yaxis[0].labels.offsetY:6,{dataLabels:{enabled:!1,style:{fontSize:`11px`}},stroke:{width:2},markers:{size:5,strokeWidth:1,strokeOpacity:1},fill:{opacity:.2},tooltip:{shared:!1,intersect:!0,followCursor:!0},grid:{show:!1,padding:{left:0,right:0,top:0,bottom:0}},xaxis:{labels:{formatter:e=>e,style:{colors:[`#a8a8a8`],fontSize:`11px`}},tooltip:{enabled:!1},crosshairs:{show:!1}}}}radialBar(){return{chart:{animations:{dynamicAnimation:{enabled:!0,speed:800}},toolbar:{show:!1}},stroke:{lineCap:`butt`},fill:{gradient:{shade:`dark`,shadeIntensity:.4,inverseColors:!1,type:`diagonal2`,opacityFrom:1,opacityTo:1,stops:[70,98,100]}},legend:{show:!1,position:`right`},tooltip:{enabled:!1,fillSeriesColor:!0},grid:{padding:{left:0,right:0,top:0,bottom:0}}}}_getBoxTooltip(e,t,n,r,i){let a=e.candleData.seriesCandleO[t][n],o=e.candleData.seriesCandleH[t][n],s=e.candleData.seriesCandleM[t][n],c=e.candleData.seriesCandleL[t][n],u=e.candleData.seriesCandleC[t][n],d=e.config.series[t];return d.type&&d.type!==i?`<div class="apexcharts-custom-tooltip">
          ${d.name?d.name:`series-`+(t+1)}: <strong>${e.seriesData.series[t][n]}</strong>
        </div>`:`<div class="apexcharts-tooltip-box apexcharts-tooltip-${e.config.chart.type}"><div>${r[0]}: <span class="value">`+a+`</span></div><div>${r[1]}: <span class="value">`+o+`</span></div>`+(s?`<div>${r[2]}: <span class="value">`+s+`</span></div>`:``)+`<div>${r[3]}: <span class="value">`+c+`</span></div><div>${r[4]}: <span class="value">`+u+`</span></div></div>`}_getViolinTooltip(e,t,n){var r,i,a;let o=(r=e.violinData.seriesViolinMin[t])==null?void 0:r[n],s=(i=e.violinData.seriesViolinMax[t])==null?void 0:i[n],c=((a=e.violinData.seriesViolinPoints[t])==null?void 0:a[n])||[],u=e.config.series[t].name||`series-`+(t+1);return`<div class="apexcharts-tooltip-box apexcharts-tooltip-${e.config.chart.type}"><div class="apexcharts-tooltip-violin-name">${u}</div><div>Min: <span class="value">${o}</span></div><div>Max: <span class="value">${s}</span></div><div>Observations: <span class="value">${c.length}</span></div></div>`}_getRaincloudTooltip(e,t,n){var r,i;let a=(r=e.violinData.seriesViolinSummary[t])==null?void 0:r[n];if(!a)return this._getViolinTooltip(e,t,n);let o=((i=e.violinData.seriesViolinPoints[t])==null?void 0:i[n])||[],s=e.config.series[t].name||`series-`+(t+1),c=e=>{if(!isFinite(e))return String(e);let t=Math.round(e);return Math.abs(e-t)<1e-6?String(t):String(Number(e.toFixed(2)))},[u,d,f,p,m]=a;return`<div class="apexcharts-tooltip-box apexcharts-tooltip-${e.config.chart.type}"><div class="apexcharts-tooltip-violin-name">${s}</div><div>Whisker high: <span class="value">${c(m)}</span></div><div>Q3: <span class="value">${c(p)}</span></div><div>Median: <span class="value">${c(f)}</span></div><div>Q1: <span class="value">${c(d)}</span></div><div>Whisker low: <span class="value">${c(u)}</span></div><div>Observations: <span class="value">${o.length}</span></div></div>`}}class Config{constructor(e){this.opts=e}init({responsiveOverride:e}){var t,n,r,i,a,o,s,c;let u=this.opts,d=new Options,f=new Defaults(u);u=this.normalizeAliasedChartType(u),this.chartType=u.chart.type,u=this.extendYAxis(u),u=this.extendAnnotations(u);let p=d.init(),m={};if(u&&typeof u==`object`){let d=Defaults.forType(u);(t=u.chart.brush)!=null&&t.enabled&&(d=f.brush(d)),(r=(n=u.plotOptions)==null?void 0:n.line)!=null&&r.isSlopeChart&&(d=f.slope()),u.chart.stacked&&u.chart.stackType===`100%`&&(u=f.stacked100(u)),(a=(i=u.plotOptions)==null?void 0:i.bar)!=null&&a.isDumbbell&&u.chart.requestedType!==`dumbbell`&&(u=f.dumbbellSizing(u)),this.checkForDarkTheme(Environment.getApex()),this.checkForDarkTheme(u),u.xaxis=u.xaxis||Environment.getApex().xaxis||{},e||(u.xaxis.convertedCatToNumeric=!1),u=this.checkForCatToNumericXAxis(this.chartType,d,u),((o=u.chart.sparkline)!=null&&o.enabled||(c=(s=Environment.getApex().chart)==null?void 0:s.sparkline)!=null&&c.enabled)&&(d=f.sparkline(d)),m=_.extend(p,d)}let h=_.extend(m,Environment.getApex());return p=_.extend(h,u),p=this.handleUserInputErrors(p),p}normalizeAliasedChartType(e){if(!e||!e.chart)return e;let t=e.chart.type;return!t||!b[t]?e:(e.chart.requestedType=t,t===`waffle`?(e.plotOptions=e.plotOptions||{},e.plotOptions.unit=e.plotOptions.unit||{},e.plotOptions.unit.layout==null&&(e.plotOptions.unit.layout=`grid`),e.plotOptions.unit.shape==null&&(e.plotOptions.unit.shape=`square`),e.chart.type=`unit`):t===`funnel`||t===`pyramid`?(e.plotOptions=e.plotOptions||{},e.plotOptions.bar=e.plotOptions.bar||{},e.plotOptions.bar.isFunnel=!0,e.plotOptions.bar.horizontal=!0,e.chart.type=`bar`,t===`pyramid`?e.plotOptions.bar.isPyramid=!0:e.plotOptions.bar.isPyramid=!1):t===`gauge`?e.chart.type=`radialBar`:t===`waterfall`?(e.chart.stacked=!1,e.chart.type=`rangeBar`):t===`dumbbell`?(e.plotOptions=e.plotOptions||{},e.plotOptions.bar=e.plotOptions.bar||{},e.plotOptions.bar.isDumbbell=!0,e.plotOptions.bar.horizontal==null&&(e.plotOptions.bar.horizontal=!0),e.chart.stacked=!1,e.chart.type=`rangeBar`):t===`streamgraph`?(e.chart.stacked=!1,e.yaxis=e.yaxis||{},!Array.isArray(e.yaxis)&&e.yaxis.show==null&&(e.yaxis.show=!1),e.chart.type=`rangeArea`):t===`histogram`?(e.xaxis=e.xaxis||{},e.xaxis.type==null&&(e.xaxis.type=`numeric`),e.chart.type=`bar`):t===`raincloud`&&(e.chart.type=`violin`),e)}checkForCatToNumericXAxis(e,t,n){var r,i,a,o,s;let c=new Defaults(n),u=(e===`bar`||e===`boxPlot`||e===`violin`)&&((i=(r=n.plotOptions)==null?void 0:r.bar)==null?void 0:i.horizontal),d=e===`pie`||e===`polarArea`||e===`donut`||e===`radar`||e===`radialBar`||e===`heatmap`||e===`unit`||e===`sunburst`,f=n.xaxis.type!==`datetime`&&n.xaxis.type!==`numeric`,p=(e===`scatter`||e===`bubble`)&&((s=(o=(a=n.plotOptions)==null?void 0:a.scatter)==null?void 0:o.jitter)==null?void 0:s.enabled),m=n.xaxis.tickPlacement?n.xaxis.tickPlacement:t.xaxis&&t.xaxis.tickPlacement;return!u&&!d&&!p&&f&&m!==`between`&&(n=c.convertCatToNumeric(n)),n}extendYAxis(e,t){let n=new Options;(e.yaxis===void 0||!e.yaxis||Array.isArray(e.yaxis)&&e.yaxis.length===0)&&(e.yaxis={});let r=Environment.getApex();e.yaxis.constructor!==Array&&r.yaxis&&r.yaxis.constructor!==Array&&(e.yaxis=_.extend(e.yaxis,r.yaxis)),e.yaxis.constructor===Array?e.yaxis=_.extendArray(e.yaxis,n.yAxis):e.yaxis=[_.extend(n.yAxis,e.yaxis)];let i=!1;e.yaxis.forEach(e=>{e.logarithmic&&(i=!0)});let a=e.series;return t&&!a&&(a=t.config.series),i&&a.length!==e.yaxis.length&&a.length&&(e.yaxis=a.map((t,r)=>{if(t.name||(a[r].name=`series-${r+1}`),e.yaxis[r])return e.yaxis[r].seriesName=a[r].name,e.yaxis[r];{let t=_.extend(n.yAxis,e.yaxis[0]);return t.show=!1,t}})),i&&a.length>1&&a.length!==e.yaxis.length&&console.warn(`A multi-series logarithmic chart should have equal number of series and y-axes`),e}extendAnnotations(e){return e.annotations===void 0&&(e.annotations={},e.annotations.yaxis=[],e.annotations.xaxis=[],e.annotations.points=[]),e=this.extendYAxisAnnotations(e),e=this.extendXAxisAnnotations(e),e=this.extendPointAnnotations(e),e}extendYAxisAnnotations(e){let t=new Options;return e.annotations.yaxis=_.extendArray(e.annotations.yaxis===void 0?[]:e.annotations.yaxis,t.yAxisAnnotation),e}extendXAxisAnnotations(e){let t=new Options;return e.annotations.xaxis=_.extendArray(e.annotations.xaxis===void 0?[]:e.annotations.xaxis,t.xAxisAnnotation),e}extendPointAnnotations(e){let t=new Options;return e.annotations.points=_.extendArray(e.annotations.points===void 0?[]:e.annotations.points,t.pointAnnotation),e}checkForDarkTheme(e){e.theme&&e.theme.mode===`dark`&&(e.tooltip||(e.tooltip={}),e.tooltip.theme!==`light`&&(e.tooltip.theme=`dark`),e.chart.foreColor||(e.chart.foreColor=`#f6f7f8`),e.theme.palette||(e.theme.palette=`palette4`))}handleUserInputErrors(e){let t=e;if(t.tooltip.shared&&t.tooltip.intersect)throw Error(`tooltip.shared cannot be enabled when tooltip.intersect is true. Turn off any other option by setting it to false.`);if(t.chart.type===`bar`&&t.plotOptions.bar.horizontal){if(t.yaxis.length>1)throw Error(`Multiple Y Axis for bars are not supported. Switch to column chart by setting plotOptions.bar.horizontal=false`);t.yaxis[0].reversed&&(t.yaxis[0].opposite=!0),t.xaxis.tooltip.enabled=!1,t.yaxis[0].tooltip.enabled=!1,t.chart.zoom.enabled=!1}return(t.chart.type===`bar`||t.chart.type===`rangeBar`)&&t.tooltip.shared&&t.xaxis.crosshairs.width===`barWidth`&&t.series.length>1&&(t.xaxis.crosshairs.width=`tickWidth`),(t.chart.type===`candlestick`||t.chart.type===`boxPlot`)&&t.yaxis[0].reversed&&(console.warn(`Reversed y-axis in ${t.chart.type} chart is not supported.`),t.yaxis[0].reversed=!1),t}}const j=1.618,M=[[1,1,2,5,5,5,10,10,10,10,10],[1,1,2,5,5,5,10,10,10,10,10]],N=[1,2,4,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,12,12,12,12,12,12,12,12,12,24];class Globals{initGlobalVars(e){e.series=[],e.seriesCandleO=[],e.seriesCandleH=[],e.seriesCandleM=[],e.seriesCandleL=[],e.seriesCandleC=[],e.seriesRangeStart=[],e.seriesRangeEnd=[],e.seriesRange=[],e.seriesPercent=[],e.seriesGoals=[],e.seriesX=[],e.seriesZ=[],e.seriesNames=[],e.seriesTotals=[],e.seriesLog=[],e.seriesColors=[],e.stackedSeriesTotals=[],e.seriesXvalues=[],e.seriesYvalues=[],e.dataWasParsed=!1,e.originalSeries=null,e.maxValsInArrayIndex=0,e.yValueDecimal=0,e.allSeriesHasEqualX=!0,e.hasNullValues=!1,e.invalidLogScale=!1,e.seriesRangeName={},e.labels=[],e.hasXaxisGroups=!1,e.groups=[],e.barGroups=[],e.lineGroups=[],e.areaGroups=[],e.hasSeriesGroups=!1,e.seriesGroups=[],e.categoryLabels=[],e.timescaleLabels=[],e.noLabelsProvided=!1,e.isXNumeric=!1,e.skipLastTimelinelabel=!1,e.skipFirstTimelinelabel=!1,e.isDataXYZ=!1,e.isMultiLineX=!1,e.isMultipleYAxis=!1,e.maxY=-Number.MAX_VALUE,e.minY=Number.MIN_VALUE,e.minYArr=[],e.maxYArr=[],e.maxX=-Number.MAX_VALUE,e.minX=Number.MAX_VALUE,e.initialMaxX=-Number.MAX_VALUE,e.initialMinX=Number.MAX_VALUE,e.maxDate=0,e.minDate=Number.MAX_VALUE,e.minZ=Number.MAX_VALUE,e.maxZ=-Number.MAX_VALUE,e.minXDiff=Number.MAX_VALUE,e.yAxisScale=[],e.xAxisScale=null,e.xAxisTicksPositions=[],e.xRange=0,e.yRange=[],e.zRange=0,e.dataPoints=0,e.xTickAmount=0,e.multiAxisTickAmount=0,e.disableZoomIn=!1,e.disableZoomOut=!1,e.yLabelsCoords=[],e.yTitleCoords=[],e.barPadForNumericAxis=0,e.padHorizontal=0,e.rotateXLabels=!1,e.overlappingXLabels=!1,e.radialSize=0,e.barHeight=0,e.barWidth=0,e.animationEnded=!1,e.isDestroyed=!1,e.bulkRevealScheduled=!1,e.resizeTimer=null,e.selectionResizeTimer=null,e.delayedElements=[],e.pointsArray=[],e.barCanvasCoords=null,e.activeRenderer=null,e.dataLabelsRects=[],e.lastDrawnDataLabelsIndexes=[],e.textRectsCache=/* @__PURE__ */ new Map,e.domCache=/* @__PURE__ */ new Map,e.dimensionCache={},e.cachedSelectors={},e.seriesNS||this._attachNamespaces(e)}_attachNamespaces(e){let t=(t,n,r=n)=>{Object.defineProperty(t,r,{get(){return e[n]},set(t){e[n]=t},enumerable:!0,configurable:!0})},n={};t(n,`series`,`data`);for(let e of/* @__PURE__ */ `seriesNames.seriesX.seriesZ.seriesXvalues.seriesYvalues.seriesGoals.seriesLog.seriesColors.seriesPercent.seriesTotals.stackedSeriesTotals.seriesCandleO.seriesCandleH.seriesCandleM.seriesCandleL.seriesCandleC.seriesRangeStart.seriesRangeEnd.seriesRange.seriesYAxisMap.seriesYAxisReverseMap.seriesGroups.barGroups.lineGroups.areaGroups.originalSeries.collapsedSeries.collapsedSeriesIndices.ancillaryCollapsedSeries.ancillaryCollapsedSeriesIndices.collapsingSeriesIndices.allSeriesCollapsed.risingSeries.previousPaths.ignoreYAxisIndexes.labels.categoryLabels.timescaleLabels.groups`.split(`.`))t(n,e);Object.defineProperty(e,"seriesNS",{value:n,writable:!1,enumerable:!1,configurable:!0});let r={};for(let e of/* @__PURE__ */ `minX.maxX.initialMinX.initialMaxX.minY.maxY.minYArr.maxYArr.minZ.maxZ.minDate.maxDate.minXDiff.xRange.yRange.zRange.xAxisScale.yAxisScale.xAxisTicksPositions.xTickAmount.multiAxisTickAmount.dataPoints.maxValsInArrayIndex.isXNumeric.isMultipleYAxis.isMultiLineX.isDataXYZ.dataFormatXNumeric.allSeriesHasEqualX.hasNullValues.dataWasParsed.hasXaxisGroups.hasSeriesGroups.skipFirstTimelinelabel.skipLastTimelinelabel.yValueDecimal.invalidLogScale.noLabelsProvided`.split(`.`))t(r,e);Object.defineProperty(e,"axes",{value:r,writable:!1,enumerable:!1,configurable:!0});let i={};for(let e of[`svgWidth`,`svgHeight`,`gridWidth`,`gridHeight`,`translateX`,`translateY`,`translateXAxisX`,`translateXAxisY`,`translateYAxisX`,`xAxisLabelsHeight`,`xAxisGroupLabelsHeight`,`xAxisLabelsWidth`,`yAxisLabelsWidth`,`yAxisWidths`,`yLabelsCoords`,`yTitleCoords`,`padHorizontal`,`barPadForNumericAxis`,`rotateXLabels`,`scaleX`,`scaleY`,`radialSize`,`defaultLabels`,`overlappingXLabels`])t(i,e);Object.defineProperty(e,"layout",{value:i,writable:!1,enumerable:!1,configurable:!0});let a={};for(let e of[`domCache`,`dimensionCache`,`cachedSelectors`,`textRectsCache`,`pointsArray`,`dataLabelsRects`,`lastDrawnDataLabelsIndexes`,`delayedElements`,`resizeTimer`,`selectionResizeTimer`,`resizeObserver`])t(a,e);Object.defineProperty(e,"cache",{value:a,writable:!1,enumerable:!1,configurable:!0})}globalVars(e){return{chartID:null,cuid:null,events:{beforeMount:[],mounted:[],updated:[],clicked:[],selection:[],dataPointSelection:[],zoomed:[],scrolled:[]},colors:[],fill:{colors:[]},radialNeedleRAF:null,unitGatherRAF:null,unitExitRAF:null,stroke:{colors:[]},dataLabels:{style:{colors:[]}},radarPolygons:{fill:{colors:[]}},markers:{colors:[],size:e.markers.size,largestSize:0,batched:!1},LINE_HEIGHT_RATIO:j,axisCharts:!0,isSlopeChart:e.plotOptions.line.isSlopeChart,comboCharts:!1,initialConfig:null,initialSeries:[],tokenSurface:void 0,lastXAxis:[],lastYAxis:[],allSeriesCollapsed:!1,collapsedSeries:[],collapsedSeriesIndices:[],ancillaryCollapsedSeries:[],ancillaryCollapsedSeriesIndices:[],collapsingSeriesIndices:[],risingSeries:[],ignoreYAxisIndexes:[],isDirty:!1,isExecCalled:!1,dataChanged:!1,resized:!1,columnSeries:null,yaxis:null,total:0,shouldAnimate:!0,previousPaths:[],prevPolarAngles:null,prevStreamFrame:null,streamScrolled:!1,prevChromeFrame:null,svgWidth:0,svgHeight:0,lastResizeSignature:null,defaultLabels:!1,yAxisLabelsWidth:0,scaleX:1,scaleY:1,translateYAxisX:[],yAxisWidths:[],tooltip:null,resizeObserver:null,locale:{},memory:{methodsToExec:[]},niceScaleAllowedMagMsd:M,niceScaleDefaultTicks:N,seriesYAxisMap:[],seriesYAxisReverseMap:[],noData:!1}}defineLazyInitialSeries(e){let t=[],n=null;Object.defineProperty(e,"initialSeries",{configurable:!0,enumerable:!0,get(){return n===null&&(n=_.clone(t)),n},set(r){t=_.copySeriesShallow(r),n=null,e._initialSeriesPeek=t}}),e._initialSeriesPeek=t}init(e){let t=this.globalVars(e);this.initGlobalVars(t),this.defineLazyInitialSeries(t);let n=_.extend({},e);return n.series=_.copySeriesShallow(e.series),t.initialConfig=n,t.initialSeries=e.series,t.lastXAxis=_.clone(t.initialConfig.xaxis),t.lastYAxis=_.clone(t.initialConfig.yaxis),t}}class Base{constructor(e){this.opts=e}init(){let e=new Config(this.opts).init({responsiveOverride:!1}),t=new Globals().init(e),n={config:e,globals:t,dom:{},interact:{zoomEnabled:e.chart.toolbar.autoSelected===`zoom`&&e.chart.toolbar.tools.zoom&&e.chart.zoom.enabled,panEnabled:e.chart.toolbar.autoSelected===`pan`&&e.chart.toolbar.tools.pan,selectionEnabled:e.chart.toolbar.autoSelected===`selection`&&e.chart.toolbar.tools.selection,measureEnabled:e.chart.toolbar.autoSelected===`measure`&&!!e.chart.toolbar.tools.measure&&!!(e.chart.measure&&e.chart.measure.enabled),zoomed:!1,selection:void 0,visibleXRange:void 0,selectedDataPoints:[],mousedown:!1,clientX:null,clientY:null,lastClientPosition:{},capturedSeriesIndex:-1,capturedDataPointIndex:-1,disableZoomIn:!1,disableZoomOut:!1,isTouchDevice:Environment.isBrowser()?`ontouchstart`in window||navigator.maxTouchPoints>0:!1},formatters:{xLabelFormatter:void 0,yLabelFormatters:[],xaxisTooltipFormatter:void 0,ttKeyFormatter:void 0,ttVal:void 0,ttZFormatter:void 0,legendFormatter:void 0},candleData:{seriesCandleO:[],seriesCandleH:[],seriesCandleM:[],seriesCandleL:[],seriesCandleC:[],seriesBoxPoints:[]},rangeData:{seriesRangeStart:[],seriesRangeEnd:[],seriesRange:[]},violinData:{seriesViolinDensity:[],seriesViolinPoints:[],seriesViolinSummary:[],seriesViolinMin:[],seriesViolinMax:[]},histogramData:{edges:[],binWidth:0,counts:[],rule:``,capped:!1},waterfallData:{values:[],cumulative:[],kinds:[],geometry:null},dumbbellData:null,streamgraphData:null,labelData:{labels:[],categoryLabels:[],timescaleLabels:[],hasXaxisGroups:!1,groups:[],seriesGroups:[]},axisFlags:{isXNumeric:!1,dataFormatXNumeric:!1,isDataXYZ:!1,isRangeData:!1,isRangeBar:!1,isMultiLineX:!1,noLabelsProvided:!1,dataWasParsed:!1},seriesData:{series:[],seriesNames:[],seriesX:[],seriesZ:[],seriesColors:[],seriesGoals:[],stackedSeriesTotals:[],stackedSeriesTotalsByGroups:[],unitData:[]},layout:{gridHeight:0,gridWidth:0,translateX:0,translateY:0,translateXAxisX:0,translateXAxisY:0,rotateXLabels:!1,xAxisHeight:0,xAxisLabelsHeight:0,xAxisGroupLabelsHeight:0,xAxisLabelsWidth:0,yLabelsCoords:[],yTitleCoords:[],gridPad:{top:0,right:0,bottom:0,left:0}}};Object.defineProperty(t,"dom",{get(){return n.dom},set(e){n.dom=e},enumerable:!1,configurable:!0});for(let e of[`xLabelFormatter`,`yLabelFormatters`,`xaxisTooltipFormatter`,`ttKeyFormatter`,`ttVal`,`ttZFormatter`,`legendFormatter`])Object.defineProperty(t,e,{get(){return n.formatters[e]},set(t){n.formatters[e]=t},enumerable:!1,configurable:!0});for(let e of[`zoomEnabled`,`panEnabled`,`selectionEnabled`,`zoomed`,`selection`,`visibleXRange`,`selectedDataPoints`,`mousedown`,`clientX`,`clientY`,`lastClientPosition`,`capturedSeriesIndex`,`capturedDataPointIndex`,`disableZoomIn`,`disableZoomOut`,`isTouchDevice`])Object.defineProperty(t,e,{get(){return n.interact[e]},set(t){n.interact[e]=t},enumerable:!1,configurable:!0});for(let e of[`gridHeight`,`gridWidth`,`translateX`,`translateY`,`translateXAxisX`,`translateXAxisY`,`rotateXLabels`,`xAxisHeight`,`xAxisLabelsHeight`,`xAxisGroupLabelsHeight`,`xAxisLabelsWidth`,`yLabelsCoords`,`yTitleCoords`,`gridPad`])Object.defineProperty(t,e,{get(){return n.layout[e]},set(t){n.layout[e]=t},enumerable:!1,configurable:!0});for(let e of[`series`,`seriesNames`,`seriesX`,`seriesZ`,`seriesColors`,`seriesGoals`,`stackedSeriesTotals`,`stackedSeriesTotalsByGroups`])Object.defineProperty(t,e,{get(){return n.seriesData[e]},set(t){n.seriesData[e]=t},enumerable:!1,configurable:!0});for(let e of[`isXNumeric`,`dataFormatXNumeric`,`isDataXYZ`,`isRangeData`,`isRangeBar`,`isMultiLineX`,`noLabelsProvided`,`dataWasParsed`])Object.defineProperty(t,e,{get(){return n.axisFlags[e]},set(t){n.axisFlags[e]=t},enumerable:!1,configurable:!0});for(let e of[`labels`,`categoryLabels`,`timescaleLabels`,`hasXaxisGroups`,`groups`,`seriesGroups`])Object.defineProperty(t,e,{get(){return n.labelData[e]},set(t){n.labelData[e]=t},enumerable:!1,configurable:!0});for(let e of[`seriesRangeStart`,`seriesRangeEnd`,`seriesRange`])Object.defineProperty(t,e,{get(){return n.rangeData[e]},set(t){n.rangeData[e]=t},enumerable:!1,configurable:!0});for(let e of[`seriesCandleO`,`seriesCandleH`,`seriesCandleM`,`seriesCandleL`,`seriesCandleC`])Object.defineProperty(t,e,{get(){return n.candleData[e]},set(t){n.candleData[e]=t},enumerable:!1,configurable:!0});for(let e of[`seriesViolinDensity`,`seriesViolinPoints`,`seriesViolinMin`,`seriesViolinMax`])Object.defineProperty(t,e,{get(){return n.violinData[e]},set(t){n.violinData[e]=t},enumerable:!1,configurable:!0});return n}}class CoreUtils{constructor(e){this.w=e}static checkComboSeries(e,t){let n=!1,r=0,i=0;return t===void 0&&(t=`line`),e.length&&e[0].type!==void 0&&e.forEach(e=>{(e.type===`bar`||e.type===`column`||e.type===`candlestick`||e.type===`boxPlot`||e.type===`violin`)&&r++,e.type!==void 0&&e.type!==t&&i++}),i>0&&(n=!0),{comboBarCount:r,comboCharts:n}}getStackedSeriesTotals(e=[]){let t=this.w,n=[];if(t.seriesData.series.length===0)return n;for(let r=0;r<t.seriesData.series[t.globals.maxValsInArrayIndex].length;r++){let i=0;for(let n=0;n<t.seriesData.series.length;n++)t.seriesData.series[n][r]!==void 0&&e.indexOf(n)===-1&&(i+=t.seriesData.series[n][r]);n.push(i)}return n}getSeriesTotalByIndex(e=null){if(e===null)return this.w.config.series.reduce((e,t)=>e+t,0);{let t=this.w.seriesData.series[e];return Array.isArray(t)?t.reduce((e,t)=>e+t,0):t==null?0:t}}getStackedSeriesTotalsByGroups(){let e=this.w,t=[];return e.labelData.seriesGroups.forEach(n=>{let r=[];e.config.series.forEach((t,i)=>{n.indexOf(e.seriesData.seriesNames[i])>-1&&r.push(i)});let i=e.seriesData.series.map((e,t)=>r.indexOf(t)===-1?t:-1).filter(e=>e!==-1);t.push(this.getStackedSeriesTotals(i))}),t}setSeriesYAxisMappings(){let e=this.w.globals,t=this.w.config,n=[],r=[],i=[],a=this.w.seriesData.series.length>t.yaxis.length||t.yaxis.some(e=>Array.isArray(e.seriesName));t.series.forEach((e,t)=>{i.push(t),r.push(null)}),t.yaxis.forEach((e,t)=>{n[t]=[]});let o=[];t.yaxis.forEach((e,r)=>{let s=!1;if(e.seriesName){let o=[];Array.isArray(e.seriesName)?o=e.seriesName:o.push(e.seriesName),o.forEach(e=>{t.series.forEach((t,o)=>{if(t.name===e){let e=o;r===o||a?!a||i.indexOf(o)>-1?n[r].push([r,o]):console.warn(`Series '`+t.name+`' referenced more than once in what looks like the new style. That is, when using either seriesName: [], or when there are more series than yaxes.`):(n[o].push([o,r]),e=r),s=!0,e=i.indexOf(e),e!==-1&&i.splice(e,1)}})})}s||o.push(r)}),n=n.map(e=>{let t=[];return e.forEach(e=>{r[e[1]]=e[0],t.push(e[1])}),t});let s=t.yaxis.length-1;for(let e=0;e<o.length&&(s=o[e],n[s]=[],i);e++){let e=i[0];i.shift(),n[s].push(e),r[e]=s}i.forEach(e=>{n[s].push(e),r[e]=s}),e.seriesYAxisMap=n.map(e=>e),e.seriesYAxisReverseMap=r.map(e=>e),e.seriesYAxisMap.forEach((e,n)=>{e.forEach(e=>{if(t.series[e]&&t.series[e].group===void 0){let r=t.series[e];r.group=`apexcharts-axis-${n.toString()}`}})})}isSeriesNull(e=null){let t=[],n=this.w.config.series;return t=e===null?n.filter(e=>e!==null):n[e]&&Array.isArray(n[e].data)?n[e].data.filter(e=>e!==null):n[e]!==null&&n[e]!==void 0?[n[e]]:[],t.length===0}seriesHaveSameValues(e){let t=this.w.seriesData.series[e];return Array.isArray(t)?t.every((e,t,n)=>e===n[0]):!0}getCategoryLabels(e){let t=this.w,n=e.slice();return t.config.xaxis.convertedCatToNumeric&&(n=e.map(e=>t.config.xaxis.labels.formatter(e-t.globals.minX+1))),n}getLargestSeries(){let e=this.w;e.globals.maxValsInArrayIndex=e.seriesData.series.map(e=>e.length).indexOf(Math.max.apply(Math,e.seriesData.series.map(e=>e.length)))}getLargestMarkerSize(){let e=this.w,t=0;return e.globals.markers.size.forEach(e=>{t=Math.max(t,e)}),e.config.markers.discrete&&e.config.markers.discrete.length&&e.config.markers.discrete.forEach(e=>{t=Math.max(t,e.size)}),t>0&&(e.config.markers.hover.size>0?t=e.config.markers.hover.size:t+=e.config.markers.hover.sizeOffset),e.globals.markers.largestSize=t,t}getSeriesTotals(){let e=this.w;e.globals.seriesTotals=e.seriesData.series.map(e=>{let t=0;if(Array.isArray(e))for(let n=0;n<e.length;n++)t+=e[n];else t+=e;return t})}getSeriesTotalsXRange(e,t){let n=this.w;return n.seriesData.series.map((r,i)=>{let a=0;for(let o=0;o<r.length;o++)n.seriesData.seriesX[i][o]>e&&n.seriesData.seriesX[i][o]<t&&(a+=r[o]);return a})}getPercentSeries(){let e=this.w;e.globals.seriesPercent=e.seriesData.series.map(t=>{let n=[];if(Array.isArray(t))for(let r=0;r<t.length;r++){let i=e.seriesData.stackedSeriesTotals[r],a=0;i&&(a=100*t[r]/i),n.push(a)}else{let r=e.globals.seriesTotals.reduce((e,t)=>e+t,0),i=100*t/r;n.push(i)}return n})}getCalculatedRatios(){let e=this.w,t=e.globals,n=[],r=0,i=0,a=0,o=0,s=[],c=.1,u=0;if(t.yRange=[],t.isMultipleYAxis)for(let e=0;e<t.minYArr.length;e++)t.yRange.push(Math.abs(t.minYArr[e]-t.maxYArr[e])),s.push(0);else t.yRange.push(Math.abs(t.minY-t.maxY));t.xRange=Math.abs(t.maxX-t.minX),t.zRange=Math.abs(t.maxZ-t.minZ);for(let e=0;e<t.yRange.length;e++)n.push(t.yRange[e]/this.w.layout.gridHeight);if(i=t.xRange/this.w.layout.gridWidth,r=t.yRange/this.w.layout.gridWidth,a=t.xRange/this.w.layout.gridHeight,o=t.zRange/this.w.layout.gridHeight*16,o||(o=1),t.minY!==Number.MIN_VALUE&&Math.abs(t.minY)!==0){let e=t;e.hasNegs=!0}if(e.globals.seriesYAxisReverseMap.length>0){let a=(t,r)=>{let i=e.config.yaxis[e.globals.seriesYAxisReverseMap[r]];if(!i||i.logarithmic)return 0;let a=t<0?-1:1;return t=Math.abs(t),-a*t/n[r]};if(t.isMultipleYAxis){s=[];for(let e=0;e<n.length;e++)s.push(a(t.minYArr[e],e))}else s=[],s.push(a(t.minY,0)),t.minY!==Number.MIN_VALUE&&Math.abs(t.minY)!==0&&(c=-t.minY/r,u=t.minX/i)}else s=[],s.push(0),c=0,u=0;return{yRatio:n,invertedYRatio:r,zRatio:o,xRatio:i,invertedXRatio:a,baseLineInvertedY:c,baseLineY:s,baseLineX:u}}getLogSeries(e){let t=this.w;return t.globals.seriesLog=e.map((e,n)=>{let r=t.globals.seriesYAxisReverseMap[n];return t.config.yaxis[r]&&t.config.yaxis[r].logarithmic?e.map(e=>e===null?null:this.getLogVal(t.config.yaxis[r].logBase,e,n)):e}),t.globals.invalidLogScale?e:t.globals.seriesLog}getLogValAtSeriesIndex(e,t){if(e===null)return null;let n=this.w,r=n.globals.seriesYAxisReverseMap[t];return n.config.yaxis[r]&&n.config.yaxis[r].logarithmic?this.getLogVal(n.config.yaxis[r].logBase,e,t):e}getBaseLog(e,t){return Math.log(t)/Math.log(e)}getLogVal(e,t,n){if(t<=0)return 0;let r=this.w,i=r.globals.minYArr[n]===0?-1:this.getBaseLog(e,r.globals.minYArr[n]),a=(r.globals.maxYArr[n]===0?0:this.getBaseLog(e,r.globals.maxYArr[n]))-i;return(this.getBaseLog(e,t)-i)/a}getLogYRatios(e){let t=this.w,n=this.w.globals,r=n;return r.yLogRatio=e.slice(),r.logYRange=n.yRange.map((e,i)=>{let a=t.globals.seriesYAxisReverseMap[i];if(t.config.yaxis[a]&&this.w.config.yaxis[a].logarithmic){let e=1;return r.yLogRatio[i]=1/this.w.layout.gridHeight,1}return n.yRange[i]}),r.invalidLogScale?e.slice():r.yLogRatio}static extendArrayProps(e,t,n){var r,i;return t!=null&&t.yaxis&&(t=e.extendYAxis(t,n)),t!=null&&t.annotations&&(t.annotations.yaxis&&(t=e.extendYAxisAnnotations(t)),(r=t==null?void 0:t.annotations)!=null&&r.xaxis&&(t=e.extendXAxisAnnotations(t)),(i=t==null?void 0:t.annotations)!=null&&i.points&&(t=e.extendPointAnnotations(t))),t}drawSeriesByGroup(e,t,n,r){let i=this.w,a=[];return e.series.length>0&&t.forEach(t=>{let o=[],s=[];e.i.forEach((n,r)=>{i.config.series[n].group===t&&(o.push(e.series[r]),s.push(n))}),o.length>0&&a.push(r.draw(o,n,s))}),a}}const P=`http://www.w3.org/2000/svg`;class Point{constructor(e,t){typeof e==`object`?(this.x=e.x,this.y=e.y):(this.x=e||0,this.y=t||0)}transform(e){return e.apply(this)}clone(){return new Point(this.x,this.y)}}class Matrix{constructor(e,t,n,r,i,a){this.a=e==null?1:e,this.b=t==null?0:t,this.c=n==null?0:n,this.d=r==null?1:r,this.e=i==null?0:i,this.f=a==null?0:a}rotate(e){let t=e*Math.PI/180,n=Math.cos(t),r=Math.sin(t);return this.multiply(new Matrix(n,r,-r,n,0,0))}scale(e,t){return this.multiply(new Matrix(e,0,0,t==null?e:t,0,0))}multiply(e){return new Matrix(this.a*e.a+this.c*e.b,this.b*e.a+this.d*e.b,this.a*e.c+this.c*e.d,this.b*e.c+this.d*e.d,this.a*e.e+this.c*e.f+this.e,this.b*e.e+this.d*e.f+this.f)}apply(e){return new Point(this.a*e.x+this.c*e.y+this.e,this.b*e.x+this.d*e.y+this.f)}}class Box{constructor(e,t,n,r){this.x=e,this.y=t,this.w=n,this.h=r,this.width=n,this.height=r,this.x2=e+n,this.y2=t+r}}
/*!
* Path morphing for SVG path animations
* Based on svg.pathmorphing.js by Ulrich-Matthias Schäfer (MIT License)
* Refactored to be standalone (no SVG.js dependency)
*
* Two algorithms are exported:
*   - morphPaths()    — command-level interpolation; preserves curves but can
*                       produce "wings/flips" when two shapes have very
*                       different topology (e.g. bar rect → pie arc).
*   - morphPolygons() — resamples both shapes into N evenly-spaced perimeter
*                       points and tweens point-by-point with rotation-search
*                       alignment; always smooth and non-self-intersecting,
*                       at the cost of throwing away curve smoothness.
*/
function F(e){if(!e||typeof e!=`string`)return[[`M`,0,0]];let t=[],n=/([MmLlHhVvCcSsQqTtAaZz])\s*/g,r=/[+-]?(?:\d+\.?\d*|\.\d+)(?:e[+-]?\d+)?/gi,i,a=[],o=[];for(;(i=n.exec(e))!==null;)a.push(i[1]),o.push(i.index);for(let n=0;n<a.length;n++){let i=o[n]+a[n].length,s=n+1<o.length?o[n+1]:e.length,c=e.substring(i,s),u=[],d;for(r.lastIndex=0;(d=r.exec(c))!==null;)u.push(parseFloat(d[0]));let f=a[n].toUpperCase();if(f===`Z`)t.push([`Z`]);else if(f===`M`||f===`L`||f===`T`)for(let e=0;e<u.length;e+=2)t.push([f,u[e],u[e+1]]);else if(f===`H`)for(let e=0;e<u.length;e++)t.push([f,u[e]]);else if(f===`V`)for(let e=0;e<u.length;e++)t.push([f,u[e]]);else if(f===`C`)for(let e=0;e<u.length;e+=6)t.push([f,u[e],u[e+1],u[e+2],u[e+3],u[e+4],u[e+5]]);else if(f===`S`||f===`Q`)for(let e=0;e<u.length;e+=4)t.push([f,u[e],u[e+1],u[e+2],u[e+3]]);else if(f===`A`)for(let e=0;e<u.length;e+=7)t.push([f,u[e],u[e+1],u[e+2],u[e+3],u[e+4],u[e+5],u[e+6]])}return t.length===0&&t.push([`M`,0,0]),t}function I(e){let t=1/0,n=1/0,r=-1/0,i=-1/0;return e.forEach(e=>{for(let a=1;a<e.length;a+=2)if(a+1<=e.length){let o=e[a],s=e[a+1];typeof o==`number`&&typeof s==`number`&&(o<t&&(t=o),o>r&&(r=o),s<n&&(n=s),s>i&&(i=s))}}),t===1/0?{x:0,y:0,width:0,height:0}:{x:t,y:n,width:r-t,height:i-n}}function L(e){return e.map(e=>e.join(` `)).join(` `)}function R(e){switch(e[0]){case`z`:case`Z`:e[0]=`L`,e[1]=this.start[0],e[2]=this.start[1];break;case`H`:e[0]=`L`,e[2]=this.pos[1];break;case`V`:e[0]=`L`,e[2]=e[1],e[1]=this.pos[0];break;case`T`:e[0]=`Q`,e[3]=e[1],e[4]=e[2],e[1]=this.reflection[1],e[2]=this.reflection[0];break;case`S`:e[0]=`C`,e[6]=e[4],e[5]=e[3],e[4]=e[2],e[3]=e[1],e[2]=this.reflection[1],e[1]=this.reflection[0];break}return e}function z(e){var t=e.length;return this.pos=[e[t-2],e[t-1]],`SCQT`.indexOf(e[0])!=-1&&(this.reflection=[2*this.pos[0]-e[t-4],2*this.pos[1]-e[t-3]]),e}function B(e){var t,n=[e];switch(e[0]){case`M`:return this.pos=this.start=[e[1],e[2]],n;case`L`:e[5]=e[3]=e[1],e[6]=e[4]=e[2],e[1]=this.pos[0],e[2]=this.pos[1];break;case`Q`:e[6]=e[4],e[5]=e[3],e[4]=e[4]*1/3+e[2]*2/3,e[3]=e[3]*1/3+e[1]*2/3,e[2]=this.pos[1]*1/3+e[2]*2/3,e[1]=this.pos[0]*1/3+e[1]*2/3;break;case`A`:n=ee((t=this.pos)==null?[]:t,e),e=n[0];break}return e[0]=`C`,this.pos=[e[5],e[6]],this.reflection=[2*e[5]-e[3],2*e[6]-e[4]],n}function V(e,t){if(t===!1)return!1;for(var n=t,r=e.length;n<r;++n)if(e[n][0]==`M`)return n;return!1}function ee(e,t){var n=Math.abs(t[1]),r=Math.abs(t[2]),i=t[3]%360,a=t[4],o=t[5],s=t[6],c=t[7],u=new Point(e[0],e[1]),d=new Point(s,c),f,p,m,h,g,_,v,y,b,x,S,C,w,T,E,D,O,k,j,M,N,P,F=[],I,L,R,z;if(n===0||r===0||u.x===d.x&&u.y===d.y)return[[`C`,u.x,u.y,d.x,d.y,d.x,d.y]];for(f=new Point((u.x-d.x)/2,(u.y-d.y)/2).transform(new Matrix().rotate(i)),p=f.x*f.x/(n*n)+f.y*f.y/(r*r),p>1&&(p=Math.sqrt(p),n=p*n,r=p*r),m=new Matrix().rotate(i).scale(1/n,1/r).rotate(-i),u=u.transform(m),d=d.transform(m),h=[d.x-u.x,d.y-u.y],_=h[0]*h[0]+h[1]*h[1],g=Math.sqrt(_),h[0]/=g,h[1]/=g,v=_<4?Math.sqrt(1-_/4):0,a===o&&(v*=-1),y=new Point((d.x+u.x)/2+v*-h[1],(d.y+u.y)/2+v*h[0]),b=new Point(u.x-y.x,u.y-y.y),x=new Point(d.x-y.x,d.y-y.y),S=Math.acos(b.x/Math.sqrt(b.x*b.x+b.y*b.y)),b.y<0&&(S*=-1),C=Math.acos(x.x/Math.sqrt(x.x*x.x+x.y*x.y)),x.y<0&&(C*=-1),o&&S>C&&(C+=2*Math.PI),!o&&S<C&&(C-=2*Math.PI),T=Math.ceil(Math.abs(S-C)*2/Math.PI),D=[],O=S,w=(C-S)/T,E=4*Math.tan(w/4)/3,N=0;N<=T;N++)j=Math.cos(O),k=Math.sin(O),M=new Point(y.x+j,y.y+k),D[N]=[new Point(M.x+E*k,M.y-E*j),M,new Point(M.x-E*k,M.y+E*j)],O+=w;for(D[0][0]=D[0][1].clone(),D[D.length-1][2]=D[D.length-1][1].clone(),m=new Matrix().rotate(i).scale(n,r).rotate(-i),N=0,P=D.length;N<P;N++)D[N][0]=D[N][0].transform(m),D[N][1]=D[N][1].transform(m),D[N][2]=D[N][2].transform(m);for(N=1,P=D.length;N<P;N++)M=D[N-1][2],I=M.x,L=M.y,M=D[N][0],R=M.x,z=M.y,M=D[N][1],s=M.x,c=M.y,F.push([`C`,I,L,R,z,s,c]);return F}function H(e,t,n,r,i,a){for(var o=e.slice(t,n||void 0),s=r.slice(i,a||void 0),c=0,u={pos:[0,0],start:[0,0]},d={pos:[0,0],start:[0,0]};o[c]=R.call(u,o[c]),s[c]=R.call(d,s[c]),o[c][0]!=s[c][0]||o[c][0]==`M`||o[c][0]==`A`&&(o[c][4]!=s[c][4]||o[c][5]!=s[c][5])?(Array.prototype.splice.apply(o,[c,1].concat(B.call(u,o[c]))),Array.prototype.splice.apply(s,[c,1].concat(B.call(d,s[c])))):(o[c]=z.call(u,o[c]),s[c]=z.call(d,s[c])),!(++c==o.length&&c==s.length);)c==o.length&&o.push([`C`,u.pos[0],u.pos[1],u.pos[0],u.pos[1],u.pos[0],u.pos[1]]),c==s.length&&s.push([`C`,d.pos[0],d.pos[1],d.pos[0],d.pos[1],d.pos[0],d.pos[1]]);return{start:o,dest:s}}function te(e,t){for(var n=F(e),r=F(t),i=0,a=0,o=!1,s=!1,c;!(i===!1&&a===!1);){if(o=V(n,i===!1?!1:i+1),s=V(r,a===!1?!1:a+1),i===!1){let e=I(c.start);i=e.height==0||e.width==0?n.push(n[0])-1:n.push([`M`,e.x+e.width/2,e.y+e.height/2])-1}if(a===!1){let e=I(c.dest);a=e.height==0||e.width==0?r.push(r[0])-1:r.push([`M`,e.x+e.width/2,e.y+e.height/2])-1}c=H(n,i,o,r,a,s),n=n.slice(0,i).concat(c.start,o===!1?[]:n.slice(o)),r=r.slice(0,a).concat(c.dest,s===!1?[]:r.slice(s)),i=o===!1?!1:i+c.start.length,a=s===!1?!1:a+c.dest.length}return{start:n,dest:r}}function ne(e,t){var n=te(e,t),r=n.start,i=n.dest;return function(e){return L(r.map(function(t,n){return i[n].map(function(r,a){return a===0?r:t[a]+(i[n][a]-t[a])*e})}))}}let U=null,W=null;function re(e,t){let n=Array(t);if(!Environment.isBrowser()){let r=I(F(e)),i=r.x+r.width/2,a=r.y+r.height/2;for(let e=0;e<t;e++)n[e]={x:i,y:a};return n}U||(U=document.createElementNS(`http://www.w3.org/2000/svg`,`svg`),U.setAttribute(`width`,`0`),U.setAttribute(`height`,`0`),U.setAttribute(`style`,`position:absolute;width:0;height:0;visibility:hidden;pointer-events:none;`),W=document.createElementNS(`http://www.w3.org/2000/svg`,`path`),U.appendChild(W),document.body.appendChild(U)),W.setAttribute(`d`,e||`M0 0`);let r=0;try{r=W.getTotalLength()}catch(e){r=0}if(!r||!isFinite(r)){let r=I(F(e)),i=r.x+r.width/2,a=r.y+r.height/2;for(let e=0;e<t;e++)n[e]={x:i,y:a};return n}for(let e=0;e<t;e++)try{let i=W.getPointAtLength(e/t*r);n[e]={x:i.x,y:i.y}}catch(t){n[e]={x:0,y:0}}return n}function ie(e,t,n=96){let r=re(e,n),i=re(t,n),a=0,o=1/0;for(let e=0;e<n;e++){let t=0;for(let a=0;a<n;a++){let s=r[(a+e)%n],c=i[a],u=s.x-c.x,d=s.y-c.y;if(t+=u*u+d*d,t>=o)break}t<o&&(o=t,a=e)}let s=Array(n);for(let e=0;e<n;e++)s[e]=r[(e+a)%n];return function(e){let t=``;for(let r=0;r<n;r++){let n=s[r],a=i[r],o=n.x+(a.x-n.x)*e,c=n.y+(a.y-n.y)*e;t+=(r===0?`M`:`L`)+o.toFixed(3)+` `+c.toFixed(3)+` `}return t+`Z`}}function ae(e){return-Math.cos(e*Math.PI)/2+.5}let oe=ae;function se(e){oe=typeof e==`function`?e:ae}function ce(e){if(!e||typeof e!=`string`)return null;if(e[0]===`#`){let t=e.slice(1);t.length===3&&(t=t[0]+t[0]+t[1]+t[1]+t[2]+t[2]);let n=parseInt(t,16);return[n>>16&255,n>>8&255,n&255,1]}let t=e.match(/rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+))?\s*\)/);return t?[+t[1],+t[2],+t[3],t[4]===void 0?1:+t[4]]:null}function le(e,t,n){return`rgba(${Math.round(e[0]+(t[0]-e[0])*n)},${Math.round(e[1]+(t[1]-e[1])*n)},${Math.round(e[2]+(t[2]-e[2])*n)},${e[3]+(t[3]-e[3])*n})`}class SVGAnimationRunner{constructor(e,t,n){this.el=e,this.duration=t==null?300:t,this.delay=n||0,this._attrTarget=null,this._plotTarget=null,this._plotSnap=null,this._plotAlgorithm=`commands`,this._afterCb=null,this._duringCb=null,this._easing=null,this._next=null,this._root=null,this._scheduled=!1}ease(e){return typeof e==`function`&&(this._easing=e),this._schedule(),this}attr(e){return this._attrTarget=e,this._schedule(),this}plot(e,t,n){return this._plotTarget=e,t&&(this._plotAlgorithm=t),this._plotSnap=n||null,this._schedule(),this}after(e){return this._afterCb=e,this._schedule(),this}during(e){return this._duringCb=e,this._schedule(),this}animate(e,t){let n=new SVGAnimationRunner(this.el,e,t);return this._next=n,n._root=this._root||this,n}_schedule(){let e=this._root||this;e._scheduled||(e._scheduled=!0,queueMicrotask(()=>e._executeChain()))}_executeChain(){let e=[],t=this;for(;t;)e.push(t),t=t._next;let n=0;e.forEach(e=>{n+=e.delay,e._execute(n),n+=e.duration})}_execute(e){let t=this.el,n=this.duration;if(n<=1){let n=()=>{this._attrTarget&&t.attr(this._attrTarget),this._plotTarget&&t.plot(this._plotSnap||this._plotTarget),this._afterCb&&this._afterCb.call(t)};e>0?setTimeout(n,e):n();return}let r=()=>{let e={},r={},i={};if(this._attrTarget)for(let n of Object.keys(this._attrTarget)){let a=t.attr(n);e[n]=a;let o=ce(a),s=ce(String(this._attrTarget[n]));o&&s&&(r[n]=o,i[n]=s)}let a=null;if(this._plotTarget){let e=t.attr(`d`)||``;try{a=this._plotAlgorithm===`polygons`?ie(e,this._plotTarget):ne(e,this._plotTarget)}catch(e){a=null}}let o=performance.now(),s=this._easing||oe,c=u=>{let d=u-o,f=Math.min(d/n,1),p=s(f);if(this._attrTarget)if(f>=1)t.attr(this._attrTarget);else{let n={};for(let t of Object.keys(this._attrTarget))if(r[t]&&i[t])n[t]=le(r[t],i[t],p);else{let r=parseFloat(e[t]),i=parseFloat(this._attrTarget[t]);!isNaN(r)&&!isNaN(i)&&(n[t]=r+(i-r)*p)}t.attr(n)}a&&f<1&&t.attr(`d`,a(p)),this._duringCb&&this._duringCb(p),f<1?BrowserAPIs.requestAnimationFrame(c):(this._plotTarget&&t.attr(`d`,this._plotSnap||this._plotTarget),this._afterCb&&this._afterCb.call(t))};BrowserAPIs.requestAnimationFrame(c)};e>0?setTimeout(r,e):r()}}function ue(e){e.prototype.animate=function(e,t){return new SVGAnimationRunner(this,e,t)}}function de(e){return-Math.cos(e*Math.PI)/2+.5}function fe(e,t,n,r){e=Math.min(Math.max(e,0),1),n=Math.min(Math.max(n,0),1);let i=3*e,a=3*(n-e)-i,o=1-i-a,s=3*t,c=3*(r-t)-s,u=1-s-c,d=e=>((o*e+a)*e+i)*e,f=e=>((u*e+c)*e+s)*e,p=e=>{let t=0,n=1,r=e;if(r<t)return t;if(r>n)return n;for(;t<n;){let i=d(r);if(Math.abs(i-e)<1e-4)return r;e>i?t=r:n=r,r=(t+n)/2}return r};return e=>e<=0?0:e>=1?1:f(p(e))}const G=/* @__PURE__ */ new Map,pe=e=>e;G.set(`linear`,pe),G.set(`easeInOutSine`,de),G.set(`easeInSine`,e=>1-Math.cos(e*Math.PI/2)),G.set(`easeOutSine`,e=>Math.sin(e*Math.PI/2)),G.set(`easeInQuad`,e=>e*e),G.set(`easeOutQuad`,e=>1-(1-e)*(1-e)),G.set(`easeInOutQuad`,e=>e<.5?2*e*e:1-(-2*e+2)**2/2),G.set(`easeInCubic`,e=>e*e*e),G.set(`easeOutCubic`,e=>1-(1-e)**3),G.set(`easeInOutCubic`,e=>e<.5?4*e*e*e:1-(-2*e+2)**3/2),G.set(`easeOutBack`,e=>{let t=1.70158,n=2.70158;return 1+2.70158*(e-1)**3+1.70158*(e-1)**2}),G.set(`easeInOutBack`,e=>{let t=1.70158,n=1.70158*1.525;return e<.5?(2*e)**2*(3.5949095*2*e-n)/2:((2*e-2)**2*(3.5949095*(e*2-2)+n)+2)/2});function me(e,t){typeof e==`string`&&e&&typeof t==`function`&&G.set(e,t)}function he(e){return Array.isArray(e)&&e.length===4&&e.every(e=>typeof e==`number`)}function ge(e){return typeof e==`function`?_e(e):he(e)?fe(e[0],e[1],e[2],e[3]):typeof e==`string`&&G.has(e)?_e(G.get(e)):de}function _e(e){return t=>{let n=e(t);return typeof n==`number`&&isFinite(n)?n:t}}const ve=`http://www.w3.org/2000/svg`;function ye(e){return 1-(1-e)**3}function be(e){let t=1.70158,n=2.70158;return 1+2.70158*(e-1)**3+1.70158*(e-1)**2}let xe=null;function Se(){if(!Environment.isBrowser())return!1;try{return xe||(xe=window.matchMedia(`(prefers-reduced-motion: reduce)`)),!!xe.matches}catch(e){return!1}}function Ce(e,t,n){if(!Environment.isBrowser()||n.globals.dataChanged||n.globals.resized)return!1;let r=n.config.chart.animations;if(!r||r.enabled===!1)return!1;let i=n.config.chart.type;if(i!==`line`&&i!==`area`&&i!==`rangeArea`||!(n.layout.gridWidth>0))return!1;let a=(r.speed||800)*2,o=Math.max(0,Math.min(1,t/n.layout.gridWidth)),s=(1-Math.cbrt(1-o))*a,c=e.node.style;c.opacity=`0`;let u=null,d=e=>{u===null&&(u=e),e-u>=s?c.opacity=``:BrowserAPIs.requestAnimationFrame(d)};return BrowserAPIs.requestAnimationFrame(d),!0}function we(e){let t=e.config.chart.animations;t&&(t.respectReducedMotion!==!1&&Se()&&(t.enabled=!1,t.dynamicAnimation&&(t.dynamicAnimation.enabled=!1)),se(ge(t.easing)))}function Te(e){let t=e.style,n=e.index||0,r=typeof e.baseDelay==`number`?e.baseDelay:40,i=e.row||0,a=e.col||0,o=e.groupIndex||0,s=e.perGroup||1,c=e.centerDistance||0;switch(t){case`none`:return 0;case`diagonal`:return(i+a)*r;case`group`:return o*r+n%s*(r/4);case`centroid`:return c*r*(n+1);default:return n*r}}class Animations{constructor(e,t){this.w=e,this.ctx=t}animateLine(e,t,n,r){e.attr(t).animate(r).attr(n)}animateMarker(e,t,n,r){e.attr({opacity:0}).animate(t).attr({opacity:1}).after(()=>{r()})}animatePop(e,{speed:t,delay:n=0,onComplete:r}){let i=this.w;if(!Environment.isBrowser()||!i.globals.shouldAnimate||t<1){r&&r();return}let a=e.node.style;a.transformBox=`fill-box`,a.transformOrigin=`center`,a.transform=`scale(0)`,a.opacity=`0`;let o=performance.now()+n,s=e=>{if(i.globals.isDestroyed)return;let n=Math.max(0,Math.min(1,(e-o)/t));a.transform=`scale(${be(n)})`,a.opacity=String(Math.min(1,n*2)),n<1?BrowserAPIs.requestAnimationFrame(s):(a.transform=``,a.transformOrigin=``,a.transformBox=``,a.opacity=``,r&&r())};BrowserAPIs.requestAnimationFrame(s)}animateRect(e,t,n,r,i,a=0){e.attr(t).animate(r,a).attr(n).after(()=>i())}animatePathsGradually(e){let{el:t,realIndex:n,j:r,fill:i,pathFrom:a,pathTo:o,pathToInterp:s,speed:c,delay:u,scrollMorph:d}=e,f=this,p=this.w,m=0;p.config.chart.animations.animateGradually.enabled&&(m=p.config.chart.animations.animateGradually.delay),p.config.chart.animations.dynamicAnimation.enabled&&p.globals.dataChanged&&p.config.chart.type!==`bar`&&(m=0),f.morphSVG(t,n,r,p.config.chart.type===`line`&&!p.globals.comboCharts?`stroke`:i,a,o,c,u*m,d,s)}revealBulk(e){let t=this.w;if(e.node.classList.add(`apexcharts-element-hidden`),t.globals.delayedElements.push({el:e.node}),!Environment.isBrowser()||!t.globals.shouldAnimate){this.animationCompleted(e);return}t.globals.bulkRevealScheduled||(t.globals.bulkRevealScheduled=!0,BrowserAPIs.requestAnimationFrame(()=>{t.globals.isDestroyed||(t.globals.bulkRevealScheduled=!1,this.animationCompleted(e))}))}showDelayedElements(){this.w.globals.delayedElements.forEach(e=>{if(e.holdUntilComplete&&!this.w.globals.animationEnded)return;let t=e.el;t.classList.remove(`apexcharts-element-hidden`),t.classList.add(`apexcharts-hidden-element-shown`)})}animationCompleted(e){let t=this.w;t.globals.animationEnded||(t.globals.animationEnded=!0,this.showDelayedElements(),typeof t.config.chart.events.animationEnd==`function`&&t.config.chart.events.animationEnd(this.ctx,{el:e,w:t}))}animateDraw(e,{realIndex:t,j:n,isFill:r,isLast:i,speed:a,delay:o,mask:s}){let c=this.w,u=this,d=()=>{i&&c.globals.shouldAnimate&&u.animationCompleted(e),u.showDelayedElements()};if(!Environment.isBrowser()||!c.globals.shouldAnimate||a<1){d();return}let f=e.node,p=()=>{let e=4,i=s&&s.type===`radial`,u=c.layout.gridWidth+8,p=s&&s.cx||0,m=s&&s.cy||0,h=(s&&s.r||c.layout.gridWidth/2)+4,g=`apexDrawMask${c.globals.cuid}-${t}-${n==null?0:n}-${r?`f`:`s`}`,_=BrowserAPIs.createElementNS(ve,`mask`);_.setAttribute(`id`,g),_.setAttribute(`maskUnits`,`userSpaceOnUse`);let v;if(i){let e=h;_.setAttribute(`x`,String(p-e)),_.setAttribute(`y`,String(m-e)),_.setAttribute(`width`,String(e*2)),_.setAttribute(`height`,String(e*2)),v=BrowserAPIs.createElementNS(ve,`circle`),v.setAttribute(`cx`,String(p)),v.setAttribute(`cy`,String(m)),v.setAttribute(`r`,`0`),v.setAttribute(`fill`,`#fff`)}else _.setAttribute(`x`,`-4`),_.setAttribute(`y`,`-4`),_.setAttribute(`width`,String(u)),_.setAttribute(`height`,String(c.layout.gridHeight+8)),v=BrowserAPIs.createElementNS(ve,`rect`),v.setAttribute(`x`,`-4`),v.setAttribute(`y`,`-4`),v.setAttribute(`width`,`0`),v.setAttribute(`height`,String(c.layout.gridHeight+8)),v.setAttribute(`fill`,`#fff`);_.appendChild(v),c.dom.elDefs.node.appendChild(_),f.setAttribute(`mask`,`url(#${g})`);let y=performance.now()+(o||0),b=e=>{if(c.globals.isDestroyed)return;let t=Math.max(0,Math.min(1,(e-y)/a)),n=ye(t);i?v.setAttribute(`r`,String(n*h)):v.setAttribute(`width`,String(n*u)),t<1?BrowserAPIs.requestAnimationFrame(b):(f.removeAttribute(`mask`),_.parentNode&&_.parentNode.removeChild(_),d())};BrowserAPIs.requestAnimationFrame(b)},m=e=>{f.setAttribute(`stroke-dasharray`,String(e)),f.setAttribute(`stroke-dashoffset`,String(e));let t=performance.now()+(o||0),n=r=>{if(c.globals.isDestroyed)return;let i=Math.max(0,Math.min(1,(r-t)/a));f.setAttribute(`stroke-dashoffset`,String(e*(1-ye(i)))),i<1?BrowserAPIs.requestAnimationFrame(n):(f.removeAttribute(`stroke-dasharray`),f.removeAttribute(`stroke-dashoffset`),d())};BrowserAPIs.requestAnimationFrame(n)};BrowserAPIs.requestAnimationFrame(()=>{if(c.globals.isDestroyed)return;if(r){p();return}let e=f.getAttribute(`stroke-dasharray`);if(e&&e!==`0`&&e!==``){p();return}let t=0;try{typeof f.getTotalLength==`function`&&(t=f.getTotalLength())}catch(e){t=0}if(!t){d();return}m(t)})}morphSVG(e,t,n,r,i,a,o,s,c,u){var d,f;let p=this.w;i||(i=e.attr(`pathFrom`)),a||(a=e.attr(`pathTo`));let m=()=>(p.config.chart.type===`radar`&&(o=1),`M 0 ${p.layout.gridHeight}`);(!i||i.indexOf(`undefined`)>-1||i.indexOf(`NaN`)>-1)&&(i=m()),(!a.trim()||a.indexOf(`undefined`)>-1||a.indexOf(`NaN`)>-1)&&(a=m(),u=void 0),u&&(!u.trim()||u.indexOf(`undefined`)>-1||u.indexOf(`NaN`)>-1)&&(u=void 0),p.globals.shouldAnimate||(o=1);let h=((f=(d=this.ctx)==null?void 0:d.morphTypeChange)==null?void 0:f.isActive())===!0?`polygons`:`commands`,g=null;if(p.globals.dataChanged){let e=p.config.chart.animations.dynamicAnimation.easing;e==null?c&&(g=ge(`linear`)):g=ge(e)}let v=e.plot(i).animate(o,s);g&&v.ease(g),v.plot(u||a,h,u?a:void 0).after(()=>{if(_.isNumber(n)){let t=p.seriesData.series[p.globals.maxValsInArrayIndex];t&&n===t.length-2&&p.globals.shouldAnimate&&this.animationCompleted(e)}else r!==`none`&&p.globals.shouldAnimate&&(!p.globals.comboCharts&&t===p.seriesData.series.length-1||p.globals.comboCharts)&&this.animationCompleted(e);this.showDelayedElements()})}}const Ee={lighten:.15,darken:.35};class Filters{constructor(e){this.w=e}static isSliceChart(e){let t=e.config.chart.type;return t===`pie`||t===`donut`||t===`polarArea`}static hoverOutlineOwnsHoverState(e){var t;return Filters.isSliceChart(e)&&e.config.states.hover.filter.type!==`none`&&((t=e.config.plotOptions.pie.hoverOutline)==null?void 0:t.show)===!0}static sliceOffsetOwnsActiveState(e){return Filters.isSliceChart(e)&&e.config.chart.type!==`polarArea`&&e.config.plotOptions.pie.expandOnClick===!0&&e.config.plotOptions.pie.expandOffset>0&&!Filters.drilldownBlocksSliceOffset(e)}static drilldownBlocksSliceOffset(e){var t;return Filters.isSliceChart(e)&&((t=e.config.drilldown)==null?void 0:t.enabled)===!0}getDefaultFilter(e,t){let n=this.w;e.unfilter&&e.unfilter(!0),n.config.chart.dropShadow.enabled&&this.dropShadow(e,n.config.chart.dropShadow,t)}applyFilter(e,t,n,r){var i,a,o;let s=this.w;if(e.unfilter&&e.unfilter(!0),n===`none`){this.getDefaultFilter(e,t);return}let c=s.config.chart.dropShadow,u=n===`lighten`?Ee.lighten:Ee.darken,d=Math.max(0,Math.min(1,typeof r==`number`?r:u)),f=1-d,p=n===`lighten`?d:0;e.filterWith&&(e.filterWith(e=>{e.colorMatrix({type:`matrix`,values:`
            ${f} 0 0 0 ${p}
            0 ${f} 0 0 ${p}
            0 0 ${f} 0 ${p}
            0 0 0 1 0
          `,in:`SourceGraphic`,result:`brightness`}),c.enabled&&this.addShadow(e,t,c,`brightness`)}),c.noUserSpaceOnUse||(a=(i=e.filterer())==null?void 0:i.node)==null||a.setAttribute(`filterUnits`,`userSpaceOnUse`),this._scaleFilterSize((o=e.filterer())==null?void 0:o.node))}addShadow(e,t,n,r){var i;let a=this.w,{blur:o,top:s,left:c,color:u,opacity:d}=n;if(u=Array.isArray(u)?u[t]:u,((i=a.config.chart.dropShadow.enabledOnSeries)==null?void 0:i.length)>0&&a.config.chart.dropShadow.enabledOnSeries.indexOf(t)===-1)return e;e.offset({in:r,dx:c,dy:s,result:`offset`}),e.gaussianBlur({in:`offset`,stdDeviation:o,result:`blur`}),e.flood({"flood-color":u,"flood-opacity":d,result:`flood`}),e.composite({in:`flood`,in2:`blur`,operator:`in`,result:`shadow`}),e.merge([`shadow`,r])}dropShadow(e,t,n=0){var r,i,a,o,s;let c=this.w;return e.unfilter&&e.unfilter(!0),_.isMsEdge()&&c.config.chart.type===`radialBar`||((r=c.config.chart.dropShadow.enabledOnSeries)==null?void 0:r.length)>0&&((i=c.config.chart.dropShadow.enabledOnSeries)==null?void 0:i.indexOf(n))===-1||e.filterWith&&(e.filterWith(e=>{this.addShadow(e,n,t,`SourceGraphic`)}),t.noUserSpaceOnUse||(o=(a=e.filterer())==null?void 0:a.node)==null||o.setAttribute(`filterUnits`,`userSpaceOnUse`),this._scaleFilterSize((s=e.filterer())==null?void 0:s.node)),e}setSelectionFilter(e,t,n){let r=this.w;if(r.interact.selectedDataPoints[t]!==void 0&&r.interact.selectedDataPoints[t].indexOf(n)>-1){if(e.node.setAttribute(`selected`,!0),Filters.sliceOffsetOwnsActiveState(r))return;let n=r.config.states.active.filter;n.type!==`none`&&this.applyFilter(e,t,n.type,n.value)}}_scaleFilterSize(e){if(!e)return;let t=t=>{for(let n in t)Object.prototype.hasOwnProperty.call(t,n)&&e.setAttribute(n,t[n])};t({width:`200%`,height:`200%`,x:`-50%`,y:`-50%`})}}class Graphics{constructor(e,t=null){this.w=e,this.ctx=t}roundPathCorners(e,t){e.indexOf(`NaN`)>-1&&(e=``);function n(e,t,n){var i=t.x-e.x,a=t.y-e.y,o=Math.sqrt(i*i+a*a);return o?r(e,t,Math.min(1,n/o)):{x:e.x,y:e.y}}function r(e,t,n){return{x:e.x+(t.x-e.x)*n,y:e.y+(t.y-e.y)*n}}function i(e,t){e.length>2&&(e[e.length-2]=t.x,e[e.length-1]=t.y)}function a(e){return{x:parseFloat(e[e.length-2]),y:parseFloat(e[e.length-1])}}var o=e.split(/[,\s]/).reduce(function(e,t){var n=t.match(/^([a-zA-Z])(.+)/);return n?(e.push(n[1]),e.push(n[2])):e.push(t),e},[]).reduce(function(e,t){return parseFloat(t)==t&&e.length?e[e.length-1].push(t):e.push([t]),e},[]),s=[];if(o.length>1){var c=a(o[0]),u=null;o[o.length-1][0]==`Z`&&o[0].length>2&&(u=[`L`,c.x,c.y],o[o.length-1]=u),s.push(o[0]);for(var d=1;d<o.length;d++){var f=s[s.length-1],p=o[d],m=p==u?o[1]:o[d+1];if(m&&f&&f.length>2&&p[0]==`L`&&m.length>2&&m[0]==`L`){var h=a(f),g=a(p),_=a(m),v=n(g,h,t),y=n(g,_,t);i(p,v),p.origPoint=g,s.push(p);var b=r(v,g,.5),x=r(g,y,.5),S=[`C`,b.x,b.y,x.x,x.y,y.x,y.y];S.origPoint=g,s.push(S)}else s.push(p)}if(u){var C=a(s[s.length-1]);s.push([`Z`]),i(s[0],C)}}else s=o;return s.reduce(function(e,t){return e+t.join(` `)+` `},``)}drawLine(e,t,n,r,i=`#a8a8a8`,a=0,o=null,s=`butt`){return this.w.dom.Paper.line().attr({x1:e,y1:t,x2:n,y2:r,stroke:i,"stroke-dasharray":a,"stroke-width":o,"stroke-linecap":s})}drawRect(e=0,t=0,n=0,r=0,i=0,a=`#fefefe`,o=1,s=null,c=null,u=0){let d=this.w.dom.Paper.rect();return d.attr({x:e,y:t,width:n>0?n:0,height:r>0?r:0,rx:i,ry:i,opacity:o,"stroke-width":s===null?0:s,stroke:c===null?`none`:c,"stroke-dasharray":u}),d.node.setAttribute(`fill`,a),d}drawPolygon(e,t=`#e1e1e1`,n=1,r=`none`){return this.w.dom.Paper.polygon(e).attr({fill:r,stroke:t,"stroke-width":n})}drawCircle(e,t=null){let n=this.w;e<0&&(e=0);let r=n.dom.Paper.circle(e*2);return t!==null&&r.attr(t),r}drawPath({d:e=``,stroke:t=`#a8a8a8`,strokeWidth:n=1,fill:r,fillOpacity:i=1,strokeOpacity:a=1,classes:o,strokeLinecap:s=null,strokeDashArray:c=0}){let u=this.w;return s===null&&(s=u.config.stroke.lineCap),(e.indexOf(`undefined`)>-1||e.indexOf(`NaN`)>-1)&&(e=`M 0 ${u.layout.gridHeight}`),u.dom.Paper.path(e).attr({fill:r,"fill-opacity":i,stroke:t,"stroke-opacity":a,"stroke-linecap":s,"stroke-width":n,"stroke-dasharray":c,class:o})}group(e=null){let t=this.w.dom.Paper.group();return e!==null&&t.attr(e),t}move(e,t){return[`M`,e,t].join(` `)}line(e,t,n=null){return n===`H`?[` H`,e].join(` `):n===`V`?[` V`,t].join(` `):[` L`,e,t].join(` `)}curve(e,t,n,r,i,a){return[`C`,e,t,n,r,i,a].join(` `)}quadraticCurve(e,t,n,r){return[`Q`,e,t,n,r].join(` `)}arc(e,t,n,r,i,a,o,s=!1){let c=`A`;return s&&(c=`a`),[c,e,t,n,r,i,a,o].join(` `)}renderPaths({j:e,realIndex:t,pathFrom:n,pathTo:r,pathToInterp:i,stroke:a,strokeWidth:o,strokeLinecap:u,fill:d,animationDelay:f,initialSpeed:p,dataChangeSpeed:m,className:h,chartType:g,shouldClipToGrid:_=!0,bindEventsOnPaths:v=!0,drawShadow:y=!0,drawMask:b=null,scrollMorph:x=!1}){var S,C,w,T;let E=this.w,D=new Filters(this.w),O=new Animations(this.w,(S=this.ctx)==null?void 0:S),k=this.w.config.chart.animations.enabled,j=k&&this.w.config.chart.animations.dynamicAnimation.enabled;if(n&&n.startsWith(`M 0 0 `)&&r){let e=r.match(/^M\s+[\d.-]+\s+[\d.-]+/);e&&(n=n.replace(/^M\s+0\s+0/,e[0]))}let M,N=((w=(C=this.ctx)==null?void 0:C.morphTypeChange)==null?void 0:w.isActive())===!0,P=!!(k&&!E.globals.resized||j&&E.globals.dataChanged&&E.globals.shouldAnimate||N&&k&&E.globals.shouldAnimate),F=typeof h==`string`&&(h.indexOf(`apexcharts-line`)>-1||h.indexOf(`apexcharts-area`)>-1||h.indexOf(`apexcharts-rangeArea`)>-1||h.indexOf(`apexcharts-radar`)>-1),I=!!(k&&!E.globals.resized&&!E.globals.dataChanged&&F),L=(T=E.config.chart.animations.largeDatasetThreshold)==null?0:T,R=!!(P&&!I&&L>0&&E.globals.dataPoints>L),z=!!((g===`candlestick`||g===`boxPlot`)&&P&&!I&&E.globals.dataChanged&&!N),B=R||z;P&&!I&&!B?M=n:(M=r,P||(E.globals.animationEnded=!0));let V=E.config.stroke.dashArray,ee=0;ee=Array.isArray(V)?V[t]:E.config.stroke.dashArray;let H=this.drawPath({d:M,stroke:a,strokeWidth:o,fill:d,fillOpacity:1,classes:h,strokeLinecap:u,strokeDashArray:ee});H.attr(`index`,t),_&&(g===`bar`&&!E.globals.isBarHorizontal||E.globals.comboCharts?H.attr({"clip-path":`url(#gridRectBarMask${E.globals.cuid})`}):H.attr({"clip-path":`url(#gridRectMask${E.globals.cuid})`})),E.config.chart.dropShadow.enabled&&y&&D.dropShadow(H,E.config.chart.dropShadow,t),v&&(H.node.addEventListener(`mouseenter`,this.pathMouseEnter.bind(this,H)),H.node.addEventListener(`mouseleave`,this.pathMouseLeave.bind(this,H)),H.node.addEventListener(`mousedown`,this.pathMouseDown.bind(this,H))),H.attr({pathTo:r,pathFrom:n});let te={el:H,j:e,realIndex:t,pathFrom:n,pathTo:r,pathToInterp:i,fill:d,strokeWidth:o,delay:f,scrollMorph:x};if(k&&!E.globals.resized&&!E.globals.dataChanged)if(I){let n=p*2,r=a===`none`||o===0,i=E.seriesData.series.length,s=E.globals.comboCharts?!0:t===i-1;O.animateDraw(H,{realIndex:t,j:e,isFill:r,isLast:s,speed:n,delay:0,mask:b})}else B||O.animatePathsGradually(c(s({},te),{speed:p}));else (E.globals.resized||!E.globals.dataChanged)&&!B&&O.showDelayedElements();return P&&!B&&(E.globals.dataChanged&&j||N)&&O.animatePathsGradually(c(s({},te),{speed:m})),B&&O.revealBulk(H),H}drawPattern(e,t,n,r=`#a8a8a8`,i=0){return this.w.dom.Paper.pattern(t,n,a=>{e===`horizontalLines`?a.line(0,0,n,0).stroke({color:r,width:i+1}):e===`verticalLines`?a.line(0,0,0,t).stroke({color:r,width:i+1}):e===`slantedLines`?a.line(0,0,t,n).stroke({color:r,width:i}):e===`squares`?a.rect(t,n).fill(`none`).stroke({color:r,width:i}):e===`circles`&&a.circle(t).fill(`none`).stroke({color:r,width:i})})}drawGradient(e,t,n,r,i,a=null,o=null,s=[],c=0,u=!1){let d=this.w,f;t.length<9&&t.indexOf(`#`)===0&&(t=_.hexToRgba(t,r)),n.length<9&&n.indexOf(`#`)===0&&(n=_.hexToRgba(n,i));let p=0,m=1,h=1,g=null;o!==null&&(p=o[0]===void 0?0:o[0]/100,m=o[1]===void 0?1:o[1]/100,h=o[2]===void 0?1:o[2]/100,g=o[3]===void 0?null:o[3]/100);let v=d.config.chart.type===`donut`||d.config.chart.type===`pie`||d.config.chart.type===`polarArea`||d.config.chart.type===`bubble`;if(f=!s||s.length===0?d.dom.Paper.gradient(v?`radial`:`linear`,e=>{e.stop(p,t,r),e.stop(m,n,i),e.stop(h,n,i),g!==null&&e.stop(g,t,r)}):d.dom.Paper.gradient(v?`radial`:`linear`,e=>{(Array.isArray(s[c])?s[c]:Array.isArray(s[0])?s[0]||[]:s).forEach(t=>{e.stop(t.offset/100,t.color,t.opacity)})}),!v)e===`vertical`?u?(f.attr({gradientUnits:`userSpaceOnUse`}),f.from(0,0).to(0,d.layout.gridHeight)):f.from(0,0).to(0,1):e===`diagonal`?f.from(0,0).to(1,1):e===`horizontal`?f.from(0,1).to(1,1):e===`diagonal2`&&f.from(1,0).to(0,1);else{let e=d.layout.gridWidth/2,t=d.layout.gridHeight/2;d.config.chart.type===`bubble`?f.attr({cx:.5,cy:.5,r:.8,fx:.2,fy:.2}):f.attr({gradientUnits:`userSpaceOnUse`,cx:e,cy:t,r:a})}return f}getTextBasedOnMaxWidth({text:e,maxWidth:t,fontSize:n,fontFamily:r}){let i=this.getTextRects(e,n,r,``),a=i.width/e.length,o=Math.floor(t/a);return t<i.width?e.slice(0,o-3)+`...`:e}drawText({x:e,y:t,text:n,textAnchor:r,fontSize:i,fontFamily:a,fontWeight:o,foreColor:c,opacity:u,maxWidth:d,cssClass:f=``,isPlainText:p=!0,dominantBaseline:m=`auto`}){let h=this.w;n===void 0&&(n=``);let g=n;r||(r=`start`),(!c||!c.length)&&(c=h.config.chart.foreColor),a=a||h.config.chart.fontFamily,i=i||`11px`,o=o||`regular`;let _={maxWidth:d,fontSize:i,fontFamily:a},v;return Array.isArray(n)?v=h.dom.Paper.text(e=>{for(let t=0;t<n.length;t++)g=n[t],d&&(g=this.getTextBasedOnMaxWidth(s({text:n[t]},_))),t===0?e.tspan(g):e.tspan(g).newLine()}):(d&&(g=this.getTextBasedOnMaxWidth(s({text:n},_))),v=p?h.dom.Paper.plain(n):h.dom.Paper.text(e=>e.tspan(g))),v.attr({x:e,y:t,"text-anchor":r,"dominant-baseline":m,"font-size":i,"font-family":a,"font-weight":o,fill:c,class:`apexcharts-text `+f}),v.node.style.fontFamily=a,v.node.style.opacity=u,v}getMarkerPath(e,t,n,r){let i=1.4,a=1.12,o=1.15,s=1.1,c=1.125,u=1.05,d=1.1,f=2,p=``;switch(n){case`cross`:r/=1.4,p=`M ${e-r} ${t-r} L ${e+r} ${t+r}  M ${e-r} ${t+r} L ${e+r} ${t-r}`;break;case`plus`:r/=1.12,p=`M ${e-r} ${t} L ${e+r} ${t}  M ${e} ${t-r} L ${e} ${t+r}`;break;case`star`:case`sparkle`:{let i=5;r*=1.15,n===`sparkle`&&(r/=1.1,i=4);let a=Math.PI/i;for(let n=0;n<=2*i;n++){let i=n*a,o=n%2==0?r:r/2,s=e+o*Math.sin(i),c=t-o*Math.cos(i);p+=(n===0?`M`:`L`)+s+`,`+c}p+=`Z`;break}case`triangle`:p=`M ${e} ${t-r} 
             L ${e+r} ${t+r} 
             L ${e-r} ${t+r} 
             Z`;break;case`square`:case`rect`:r/=1.125,p=`M ${e-r} ${t-r} 
           L ${e+r} ${t-r} 
           L ${e+r} ${t+r} 
           L ${e-r} ${t+r} 
           Z`;break;case`diamond`:r*=1.05,p=`M ${e} ${t-r} 
             L ${e+r} ${t} 
             L ${e} ${t+r} 
             L ${e-r} ${t} 
            Z`;break;case`line`:r/=1.1,p=`M ${e-r} ${t} 
           L ${e+r} ${t}`;break;default:r*=2,p=`M ${e}, ${t} 
           m -${r/2}, 0 
           a ${r/2},${r/2} 0 1,0 ${r},0 
           a ${r/2},${r/2} 0 1,0 -${r},0`;break}return p}drawMarkerShape(e,t,n,r,i){let a=this.drawPath({d:this.getMarkerPath(e,t,n,r),stroke:i.pointStrokeColor,strokeDashArray:i.pointStrokeDashArray,strokeWidth:i.pointStrokeWidth,fill:i.pointFillColor,fillOpacity:i.pointFillOpacity,strokeOpacity:i.pointStrokeOpacity});return a.attr({cx:e,cy:t,shape:i.shape,class:i.class?i.class:``}),a}drawMarker(e,t,n){e=e||0;let r=n.pSize||0;return _.isNumber(t)||(r=0,t=0),this.drawMarkerShape(e,t,n==null?void 0:n.shape,r,s(s({},n),n.shape===`line`||n.shape===`plus`||n.shape===`cross`?{pointStrokeColor:n.pointFillColor,pointStrokeOpacity:n.pointFillOpacity}:{}))}pathMouseEnter(e,t){var n,r;let i=this.w,a=new Filters(this.w),o=parseInt((n=e.node.getAttribute(`index`))==null?``:n,10),s=parseInt((r=e.node.getAttribute(`j`))==null?``:r,10);if(!(isNaN(o)||isNaN(s))&&(typeof i.config.chart.events.dataPointMouseEnter==`function`&&i.config.chart.events.dataPointMouseEnter(t,this.ctx,{seriesIndex:o,dataPointIndex:s,w:i}),Graphics._fireEvent(i,`dataPointMouseEnter`,[t,this.ctx,{seriesIndex:o,dataPointIndex:s,w:i}]),!(i.config.states.active.filter.type!==`none`&&e.node.getAttribute(`selected`)===`true`)&&!Filters.hoverOutlineOwnsHoverState(i)&&i.config.states.hover.filter.type!==`none`&&!i.interact.isTouchDevice)){let t=i.config.states.hover.filter;a.applyFilter(e,o,t.type,t.value)}}pathMouseLeave(e,t){var n,r;let i=this.w,a=new Filters(this.w),o=parseInt((n=e.node.getAttribute(`index`))==null?``:n,10),s=parseInt((r=e.node.getAttribute(`j`))==null?``:r,10);isNaN(o)||isNaN(s)||(typeof i.config.chart.events.dataPointMouseLeave==`function`&&i.config.chart.events.dataPointMouseLeave(t,this.ctx,{seriesIndex:o,dataPointIndex:s,w:i}),Graphics._fireEvent(i,`dataPointMouseLeave`,[t,this.ctx,{seriesIndex:o,dataPointIndex:s,w:i}]),!(i.config.states.active.filter.type!==`none`&&e.node.getAttribute(`selected`)===`true`)&&(Filters.hoverOutlineOwnsHoverState(i)||i.config.states.hover.filter.type!==`none`&&a.getDefaultFilter(e,o)))}_clearAllDataPointSelections(e,t){let n=this.w;n.interact.selectedDataPoints=[];let r=n.dom.Paper.find(`.apexcharts-series path:not(.apexcharts-decoration-element)`),i=n.dom.Paper.find(`.apexcharts-series circle:not(.apexcharts-decoration-element), .apexcharts-series rect:not(.apexcharts-decoration-element)`),a=n=>{Array.prototype.forEach.call(n,n=>{n.node.setAttribute(`selected`,`false`),e.getDefaultFilter(n,t)})};a(r),a(i)}_togglePointSelection(e,t,n,r){let i=this.w;if(e.node.getAttribute(`selected`)===`true`){e.node.setAttribute(`selected`,`false`);let t=i.interact.selectedDataPoints[n].indexOf(r);return t>-1&&i.interact.selectedDataPoints[n].splice(t,1),`false`}return!i.config.states.active.allowMultipleDataPointsSelection&&i.interact.selectedDataPoints.length>0&&this._clearAllDataPointSelections(t,n),e.node.setAttribute(`selected`,`true`),i.interact.selectedDataPoints[n]===void 0&&(i.interact.selectedDataPoints[n]=[]),i.interact.selectedDataPoints[n].push(r),`true`}_applyPointSelectionFilter(e,t,n,r){let i=this.w;if(!Filters.sliceOffsetOwnsActiveState(i)){if(r===`true`){let r=i.config.states.active.filter;if(r!==`none`)t.applyFilter(e,n,r.type,r.value);else if(i.config.states.hover.filter!==`none`&&!i.interact.isTouchDevice){let r=i.config.states.hover.filter;t.applyFilter(e,n,r.type,r.value)}}else if(i.config.states.active.filter.type!==`none`)if(i.config.states.hover.filter.type!==`none`&&!i.interact.isTouchDevice){let r=i.config.states.hover.filter;t.applyFilter(e,n,r.type,r.value)}else t.getDefaultFilter(e,n)}}pathMouseDown(e,t){var n,r;let i=this.w,a=new Filters(this.w),o=parseInt((n=e.node.getAttribute(`index`))==null?``:n,10),s=parseInt((r=e.node.getAttribute(`j`))==null?``:r,10);if(isNaN(o)||isNaN(s))return;let c=i.config.chart.link;if(!(c&&(typeof c.dimension==`function`||c.enabled))){let t=this._togglePointSelection(e,a,o,s);this._applyPointSelectionFilter(e,a,o,t)}typeof i.config.chart.events.dataPointSelection==`function`&&i.config.chart.events.dataPointSelection(t,this.ctx,{selectedDataPoints:i.interact.selectedDataPoints,seriesIndex:o,dataPointIndex:s,w:i}),t&&Graphics._fireEvent(i,`dataPointSelection`,[t,this.ctx,{selectedDataPoints:i.interact.selectedDataPoints,seriesIndex:o,dataPointIndex:s,w:i}])}rotateAroundCenter(e){let t={};return e&&typeof e.getBBox==`function`&&(t=e.getBBox()),{x:t.x+t.width/2,y:t.y+t.height/2}}setupEventDelegation(e,t){let n=null;e.node.addEventListener(`mouseover`,r=>{let i=Graphics._findDelegateTarget(r.target,e.node,t);!i||i===n||(n&&n.instance&&this.pathMouseLeave(n.instance,r),n=i,i.instance&&this.pathMouseEnter(i.instance,r))}),e.node.addEventListener(`mouseout`,r=>{n&&(r.relatedTarget?Graphics._findDelegateTarget(r.relatedTarget,e.node,t):null)!==n&&(n&&n.instance&&this.pathMouseLeave(n.instance,r),n=null)}),e.node.addEventListener(`mousedown`,n=>{let r=Graphics._findDelegateTarget(n.target,e.node,t);r&&r.instance&&this.pathMouseDown(r.instance,n)})}static _fireEvent(e,t,n){let r=e.globals.events;if(!r||!Object.prototype.hasOwnProperty.call(r,t))return;let i=r[t];for(let e=0;e<i.length;e++)i[e].apply(null,n)}static _findDelegateTarget(e,t,n){for(;e&&e!==t&&e!==document;){if(e.matches&&e.matches(n))return e;e=e.parentNode}return null}static setAttrs(e,t){for(let n in t)Object.prototype.hasOwnProperty.call(t,n)&&e.setAttribute(n,t[n])}getTextRects(e,t,n,r,i=!0,a){let o=this.w,s=[e,t,n,r,i,a].join(`\0`),c=o.globals.textRectsCache;if(c&&c.has(s))return c.get(s);let u=this.drawText({x:-200,y:-200,text:e,textAnchor:`start`,fontSize:t,fontFamily:n,fontWeight:a,foreColor:`#fff`,opacity:0});r&&u.attr(`transform`,r),o.dom.Paper.add(u);let d=u.bbox(),f=d.y;i||(d=u.node.getBoundingClientRect()),u.remove();let p={width:d.width,height:d.height,centerOffset:i?f+d.height/2- -200:0};return c&&c.set(s,p),p}placeTextWithEllipsis(e,t,n){if(typeof e.getComputedTextLength==`function`&&(e.textContent=t,t.length>0&&e.getComputedTextLength()>=n/1.1)){for(let r=t.length-3;r>0;r-=3)if(e.getSubStringLength(0,r)<=n/1.1){e.textContent=t.substring(0,r)+`...`;return}e.textContent=`.`}}}class Fill{constructor(e){this.w=e,this.opts=null,this.seriesIndex=0,this.patternIDs=[]}clippedImgArea(e){let t=this.w,n=t.config,r=parseInt(String(t.layout.gridWidth),10),i=parseInt(String(t.layout.gridHeight),10),a=r>i?r:i,o=e.image,s=0,c=0;e.width===void 0&&e.height===void 0?n.fill.image.width!==void 0&&n.fill.image.height!==void 0?(s=n.fill.image.width+1,c=n.fill.image.height):(s=a+1,c=a):(s=e.width,c=e.height);let u=BrowserAPIs.createElementNS(P,`pattern`);Graphics.setAttrs(u,{id:e.patternID,patternUnits:e.patternUnits?e.patternUnits:`userSpaceOnUse`,width:s+`px`,height:c+`px`});let d=BrowserAPIs.createElementNS(P,`image`);u.appendChild(d);let f=Environment.isBrowser()?window.SVG:global.SVG;d.setAttributeNS(f.xlink,`href`,o),Graphics.setAttrs(d,{x:0,y:0,preserveAspectRatio:`none`,width:s+`px`,height:c+`px`}),d.style.opacity=e.opacity,t.dom.elDefs.node.appendChild(u)}getSeriesIndex(e){let t=this.w,n=t.config.chart.type;return(n===`bar`||n===`rangeBar`)&&t.config.plotOptions.bar.distributed||n===`heatmap`||n===`treemap`?this.seriesIndex=e.seriesNumber:this.seriesIndex=e.seriesNumber%t.seriesData.series.length,this.seriesIndex}getSeriesAxisRange(e){var t,n,r;let i=this.w,a=(n=(t=i.globals.seriesYAxisReverseMap)==null?void 0:t[e])==null?0:n;return{minY:_.isNumber(i.globals.minYArr[e])?i.globals.minYArr[e]:i.globals.minY,maxY:_.isNumber(i.globals.maxYArr[e])?i.globals.maxYArr[e]:i.globals.maxY,reversed:!!((r=i.config.yaxis[a])!=null&&r.reversed)}}computeColorStops(e,t){let n=this.w,{threshold:r,colorAboveThreshold:i,colorBelowThreshold:a}=t,{minY:o,maxY:s}=e,c=s-o,u=c===0?r>s?0:100:(s-r)/c*100;e.reversed&&(u=100-u),u=Math.max(0,Math.min(u,100));let d=Array.isArray(n.config.fill.opacity)?n.config.fill.opacity[this.seriesIndex]:n.config.fill.opacity,f={offset:u,color:i,opacity:d},p={offset:u,color:a,opacity:d};return e.reversed?[p,f]:[f,p]}fillPath(e){var t,n,r,i,a,o,s;let c=this.w;this.opts=e;let u=this.w.config,d,f,p;this.seriesIndex=this.getSeriesIndex(e);let m=u.plotOptions.line.colors.colorAboveThreshold&&u.plotOptions.line.colors.colorBelowThreshold,h=this.getFillColors()[this.seriesIndex];c.seriesData.seriesColors[this.seriesIndex]!==void 0&&(h=c.seriesData.seriesColors[this.seriesIndex]),typeof h==`function`&&(h=h({seriesIndex:this.seriesIndex,dataPointIndex:e.dataPointIndex,value:e.value,w:c}));let g=e.fillType?e.fillType:this.getFillType(this.seriesIndex),v=Array.isArray(u.fill.opacity)?u.fill.opacity[this.seriesIndex]:u.fill.opacity,y=g===`gradient`||m;e.color&&(h=e.color);let b=c.config.series[this.seriesIndex];(n=(t=b==null?void 0:b.data)==null?void 0:t[e.dataPointIndex])!=null&&n.fillColor&&(h=(i=(r=b==null?void 0:b.data)==null?void 0:r[e.dataPointIndex])==null?void 0:i.fillColor),h||(h=`#fff`,console.warn(`undefined color - ApexCharts`)),e.opacity!==void 0&&e.opacity!==null&&(v=e.opacity);let x=h;_.isCSSVariable(h)?x=_.applyOpacityToColor(h,v):h.indexOf(`rgb`)===-1?h.indexOf(`#`)===-1?x=h:h.length<9&&(x=_.hexToRgba(h,v)):h.indexOf(`rgba`)>-1?v=_.getOpacityFromRGBA(h):x=_.hexToRgba(_.rgb2hex(h),v);let S=_.isCSSVariable(h)?_.getThemeColor(h):h;if(g===`pattern`&&(f=this.handlePatternFill({fillConfig:e.fillConfig,patternFill:f,fillColor:S,defaultColor:x})),y){let t=u.fill.gradient.colorStops?[...u.fill.gradient.colorStops]:[],n=(s=(o=(a=e.fillConfig)==null?void 0:a.gradient)==null?void 0:o.type)==null?u.fill.gradient.type:s;m&&(t[this.seriesIndex]=this.computeColorStops(this.getSeriesAxisRange(this.seriesIndex),u.plotOptions.line.colors),n=`vertical`),p=this.handleGradientFill({type:n,fillConfig:e.fillConfig,fillColor:S,fillOpacity:v,colorStops:t,i:this.seriesIndex,verticalUserSpace:m})}if(g===`image`){let t=u.fill.image.src,n=e.patternID?e.patternID:``,r=`pattern${c.globals.cuid}${e.seriesNumber+1}${n}`;this.patternIDs.indexOf(r)===-1&&(this.clippedImgArea({opacity:v,image:Array.isArray(t)?e.seriesNumber<t.length?t[e.seriesNumber]:t[0]:t,width:e.width?e.width:void 0,height:e.height?e.height:void 0,patternUnits:e.patternUnits,patternID:r}),this.patternIDs.push(r)),d=`url(#${r})`}else d=y?p:g===`pattern`?f:x;return e.solid&&(d=x),d}getFillType(e){let t=this.w;return Array.isArray(t.config.fill.type)?t.config.fill.type[e]:t.config.fill.type}getFillColors(){let e=this.w,t=e.config,n=this.opts,r=[];return e.globals.comboCharts?e.config.series[this.seriesIndex].type===`line`?Array.isArray(e.globals.stroke.colors)?r=e.globals.stroke.colors:r.push(e.globals.stroke.colors):Array.isArray(e.globals.fill.colors)?r=e.globals.fill.colors:r.push(e.globals.fill.colors):t.chart.type===`line`?Array.isArray(e.globals.stroke.colors)?r=e.globals.stroke.colors:r.push(e.globals.stroke.colors):Array.isArray(e.globals.fill.colors)?r=e.globals.fill.colors:r.push(e.globals.fill.colors),n.fillColors!==void 0&&(r=[],Array.isArray(n.fillColors)?r=n.fillColors.slice():r.push(n.fillColors)),r}handlePatternFill({fillConfig:e,patternFill:t,fillColor:n,defaultColor:r}){let i=this.w.config.fill;e&&(i=e);let a=this.opts,o=new Graphics(this.w),s=Array.isArray(i.pattern.strokeWidth)?i.pattern.strokeWidth[this.seriesIndex]:i.pattern.strokeWidth,c=n;return t=Array.isArray(i.pattern.style)?i.pattern.style[a.seriesNumber]===void 0?r:o.drawPattern(i.pattern.style[a.seriesNumber],i.pattern.width,i.pattern.height,c,s):o.drawPattern(i.pattern.style,i.pattern.width,i.pattern.height,c,s),t}handleGradientFill({type:e,fillColor:t,fillOpacity:n,fillConfig:r,colorStops:i,i:a,verticalUserSpace:o=!1}){let c=this.w.config.fill;r&&(c=s(s({},c),r));let u=this.opts,d=new Graphics(this.w),f=new _;e=e||c.gradient.type;let p=t,m,h=c.gradient.opacityFrom===void 0?n:Array.isArray(c.gradient.opacityFrom)?c.gradient.opacityFrom[a]:c.gradient.opacityFrom;p.indexOf(`rgba`)>-1&&(h=_.getOpacityFromRGBA(p));let g=c.gradient.opacityTo===void 0?n:Array.isArray(c.gradient.opacityTo)?c.gradient.opacityTo[a]:c.gradient.opacityTo;if(c.gradient.gradientToColors===void 0||c.gradient.gradientToColors.length===0)m=c.gradient.shade===`dark`?f.shadeColor(parseFloat(c.gradient.shadeIntensity)*-1,t.indexOf(`rgb`)>-1?_.rgb2hex(t):t):f.shadeColor(parseFloat(c.gradient.shadeIntensity),t.indexOf(`rgb`)>-1?_.rgb2hex(t):t);else if(c.gradient.gradientToColors[u.seriesNumber]){let e=c.gradient.gradientToColors[u.seriesNumber];m=e,e.indexOf(`rgba`)>-1&&(g=_.getOpacityFromRGBA(e))}else m=t;if(c.gradient.gradientFrom&&(p=c.gradient.gradientFrom),c.gradient.gradientTo&&(m=c.gradient.gradientTo),c.gradient.inverseColors){let e=p;p=m,m=e}return p.indexOf(`rgb`)>-1&&(p=_.rgb2hex(p)),m.indexOf(`rgb`)>-1&&(m=_.rgb2hex(m)),d.drawGradient(e,p,m,h,g,u.size,c.gradient.stops,i,a,o)}}const De=[`none`,`lighten`,`darken`];function Oe(e,t){let n=e&&e.renderer;return n&&n.kind&&n.kind!==`svg`?n:t}function ke(e){let t=e.config.series||[],n=e.config.chart.type,r=n===`scatter`||n===`bubble`,i=e.config.markers&&e.config.markers.size,a=Array.isArray(i)?i.some(e=>e>0):(i||0)>0,o=!!(e.config.dataLabels&&e.config.dataLabels.enabled),s=n===`heatmap`,c=0,u=0;t.forEach(e=>{let t=Array.isArray(e.data)?e.data.length:0;t>u&&(u=t),(r||a||s)&&(c+=t),o&&(c+=t)});let d=5e4;return u>=5e4&&(c=Math.max(c,u)),c}function Ae(e){var t,n,r,i;let a=e.config.fill&&e.config.fill.type,o=e=>e===`pattern`||e===`image`||e===`gradient`;if(Array.isArray(a)?a.some(o):o(a))return!0;let s=(n=(t=e.config.plotOptions)==null?void 0:t.line)==null?void 0:n.colors;if(s&&s.colorAboveThreshold&&s.colorBelowThreshold||e.config.chart.type===`heatmap`&&(((i=(r=e.config.plotOptions)==null?void 0:r.heatmap)==null?void 0:i.shape)||`rect`)!==`rect`)return!0;let c=e.config.states||{},u=c.hover&&c.hover.filter&&c.hover.filter.type,d=c.active&&c.active.filter&&c.active.filter.type;return!!(u&&!De.includes(u)||d&&!De.includes(d))}class Markers{constructor(e,t){this.w=e,this.ctx=t,this._filters=new Filters(this.w),this._graphics=new Graphics(this.w,this.ctx),this._seriesWrap=null,this._seriesWrapIndex=-1,this._batch=null}resetSeriesWrapCache(){this._seriesWrap=null,this._seriesWrapIndex=-1,this._batch=null}static markersAreInert(e){let t=e.config.chart.type;return(t===`line`||t===`area`)&&!e.globals.comboCharts&&!e.config.tooltip.intersect}_shouldBatch(){var e,t,n,r,i;let a=this.w,o=a.config.markers,s=(e=o.largeDatasetThreshold)==null?0:e;if(s<=0||((n=(t=this.ctx)==null?void 0:t.renderer)==null?void 0:n.kind)===`canvas`||!Markers.markersAreInert(a)||o.discrete&&o.discrete.length||o.onClick||o.onDblClick||(r=a.config.chart.events)!=null&&r.dataPointSelection)return!1;let c=a.seriesData.series;if(!Array.isArray(c)||!c.length)return!1;let u=!1;for(let e=0;e<c.length;e++){if(!Array.isArray(c[e]))return!1;let t=!1,n=!1,r=(i=a.config.series[e])==null?void 0:i.data;for(let i=0;i<c[e].length;i++){c[e][i]===null&&(t=!0);let a=Array.isArray(r)?r[i]:null;if(a&&(a.fillColor||a.strokeColor)){n=!0;break}}if(n)return!1;(a.globals.markers.size[e]>0||t&&o.showNullDataPoints)&&c[e].length>s&&(u=!0)}return u}setGlobalMarkerSize(){let e=this.w;if(e.globals.markers.size=Array.isArray(e.config.markers.size)?e.config.markers.size:[e.config.markers.size],e.globals.markers.size.length>0){if(e.globals.markers.size.length<e.seriesData.series.length+1)for(let t=0;t<=e.seriesData.series.length;t++)e.globals.markers.size[t]===void 0&&e.globals.markers.size.push(e.globals.markers.size[0])}else e.globals.markers.size=e.config.series.map(()=>e.config.markers.size);e.globals.markers.batched=this._shouldBatch()}plotChartMarkers({pointsPos:e,seriesIndex:t,j:n,pSize:r,alwaysDrawMarker:i=!1,isVirtualPoint:a=!1}){let o=this.w,s=t,c=e,u=null,d=new Graphics(this.w),f=Oe(this.ctx,d),p=o.config.markers.discrete&&o.config.markers.discrete.length;if(Array.isArray(c.x))for(let e=0;e<c.x.length;e++){let m,h=n,g=!_.isNumber(c.y[e]);o.globals.markers.largestSize===0&&o.globals.hasNullValues&&o.seriesData.series[s][n+1]!==null&&!a&&(g=!0),n===1&&e===0&&(h=0),n===1&&e===1&&(h=1);let v=`apexcharts-marker`;Markers.markersAreInert(o)&&(v+=` no-pointer-events`);let y=Array.isArray(o.config.markers.size)?o.globals.markers.size[t]>0:o.config.markers.size>0;if(o.globals.markers.batched&&(y||i)&&!p&&!a){this._batchPoint(t,h,c.x[e],c.y[e],{invalid:g,graphics:d,pSize:i?r:void 0,trackPoint:!i});continue}if(y||i||p){f.kind===`canvas`&&(o.globals.pointsArray[t]===void 0&&(o.globals.pointsArray[t]=[]),o.globals.pointsArray[t][h]=[c.x[e],c.y[e]]),g||(v+=` w${_.randomId()}`);let n=this.getMarkerConfig({cssClass:v,seriesIndex:t,dataPointIndex:h}),a=o.config.series[s];if(a.data[h]&&(a.data[h].fillColor&&(n.pointFillColor=a.data[h].fillColor),a.data[h].strokeColor&&(n.pointStrokeColor=a.data[h].strokeColor)),r!==void 0&&(n.pSize=r),(c.x[e]<-o.globals.markers.largestSize||c.x[e]>o.layout.gridWidth+o.globals.markers.largestSize||c.y[e]<-o.globals.markers.largestSize||c.y[e]>o.layout.gridHeight+o.globals.markers.largestSize)&&(n.pSize=0),!g){if((o.globals.markers.size[t]>0||i||p)&&!u){let e=!i&&!p;e&&this._seriesWrap&&this._seriesWrapIndex===t?u=this._seriesWrap:(u=f.group({class:e?`apexcharts-series-markers`:``}),u.attr(`clip-path`,`url(#gridRectMarkerMask${o.globals.cuid})`),this.setupMarkerDelegation(u),e&&(this._seriesWrap=u,this._seriesWrapIndex=t))}m=f.drawMarker(c.x[e],c.y[e],n),m.attr(`rel`,h),m.attr(`j`,h),m.attr(`index`,t),m.node.setAttribute(`default-marker-size`,n.pSize),Ce(m,c.x[e],o),this._filters.setSelectionFilter(m,t,h),u&&u.add(m)}}else o.globals.pointsArray[t]===void 0&&(o.globals.pointsArray[t]=[]),o.globals.pointsArray[t].push([c.x[e],c.y[e]])}return u}_batchPoint(e,t,n,r,{invalid:i,graphics:a,pSize:o,trackPoint:s}){let c=this.w;if(s&&(c.globals.pointsArray[e]===void 0&&(c.globals.pointsArray[e]=[]),c.globals.pointsArray[e][t]=[n,r]),i)return;(!this._batch||this._batch.seriesIndex!==e)&&(this._batch={seriesIndex:e,opts:this.getMarkerConfig({cssClass:``,seriesIndex:e}),sizes:/* @__PURE__ */ new Map});let u=o===void 0?this._batch.opts.pSize:o;if(!(u>0))return;let d=c.globals.markers.largestSize;if(n<-d||n>c.layout.gridWidth+d||r<-d||r>c.layout.gridHeight+d)return;let f=this._batch.sizes.get(u);f||(f=[],this._batch.sizes.set(u,f)),f.push(a.getMarkerPath(n,r,this._batch.opts.shape,u))}flushBatch(e,t){let n=this._batch;if(this._batch=null,!n||n.seriesIndex!==t||!n.sizes.size)return[];let r=this.w,i=new Graphics(this.w),a=n.opts,o=a.shape===`line`||a.shape===`plus`||a.shape===`cross`,s=o?a.pointFillColor:a.pointStrokeColor,c=o?a.pointFillOpacity:a.pointStrokeOpacity,u=[];return n.sizes.forEach((n,o)=>{if(!n.length)return;let d=i.drawPath({d:n.join(` `),fill:a.pointFillColor,fillOpacity:a.pointFillOpacity,stroke:s,strokeOpacity:c,strokeWidth:a.pointStrokeWidth,strokeDashArray:a.pointStrokeDashArray});d.attr({class:`apexcharts-marker-batch${Markers.markersAreInert(r)?` no-pointer-events`:``}`,"clip-path":`url(#gridRectMarkerMask${r.globals.cuid})`,shape:a.shape,index:t,"default-marker-size":o}),e.add(d),u.push(d)}),u}getMarkerConfig({cssClass:e,seriesIndex:t,dataPointIndex:n=null,radius:r=null,size:i=null,strokeWidth:a=null}){let o=this.w,s=this.getMarkerStyle(t),c=i===null?o.globals.markers.size[t]:i,u=o.config.markers;return n!==null&&u.discrete.length&&u.discrete.map(e=>{e.seriesIndex===t&&e.dataPointIndex===n&&(e.strokeColor!==void 0&&(s.pointStrokeColor=e.strokeColor),e.fillColor!==void 0&&(s.pointFillColor=e.fillColor),e.size!==void 0&&(c=e.size),e.shape!==void 0&&(s.pointShape=e.shape))}),{pSize:r===null?c:r,pRadius:r===null?u.radius:r,pointStrokeWidth:a===null?Array.isArray(u.strokeWidth)?u.strokeWidth[t]:u.strokeWidth:a,pointStrokeColor:s.pointStrokeColor,pointFillColor:s.pointFillColor,shape:s.pointShape||(Array.isArray(u.shape)?u.shape[t]:u.shape),class:e,pointStrokeOpacity:Array.isArray(u.strokeOpacity)?u.strokeOpacity[t]:u.strokeOpacity,pointStrokeDashArray:Array.isArray(u.strokeDashArray)?u.strokeDashArray[t]:u.strokeDashArray,pointFillOpacity:Array.isArray(u.fillOpacity)?u.fillOpacity[t]:u.fillOpacity,seriesIndex:t}}setupMarkerDelegation(e){let t=this.w,n=`.apexcharts-marker`;this._graphics.setupEventDelegation(e,n),e.node.addEventListener(`click`,r=>{t.config.markers.onClick&&Graphics._findDelegateTarget(r.target,e.node,n)&&t.config.markers.onClick(r)}),e.node.addEventListener(`dblclick`,r=>{t.config.markers.onDblClick&&Graphics._findDelegateTarget(r.target,e.node,n)&&t.config.markers.onDblClick(r)}),e.node.addEventListener(`touchstart`,t=>{let r=Graphics._findDelegateTarget(t.target,e.node,n);r&&r.instance&&this._graphics.pathMouseDown(r.instance,t)},{passive:!0})}getMarkerStyle(e){let t=this.w,n=t.globals.markers.colors,r=t.config.markers.strokeColor||t.config.markers.strokeColors;return{pointStrokeColor:Array.isArray(r)?r[e]:r,pointFillColor:Array.isArray(n)?n[e]:n}}}class Scatter{constructor(e,t){this.ctx=t,this.w=e,this.initialAnim=this.w.config.chart.animations.enabled,this.anim=new Animations(this.w),this.filters=new Filters(this.w),this.fill=new Fill(this.w),this.markers=new Markers(this.w,this.ctx),this.graphics=new Graphics(this.w),this._elPointsWrap=null,this._elPointsWrapParent=null,this._perSeries=null}draw(e,t,n){let r=this.w,i=this.graphics,a=Oe(this.ctx,i),o=n.realIndex,s=n.pointsPos,c=n.zRatio,u=n.elParent,d=this._elPointsWrap;if((!d||this._elPointsWrapParent!==u)&&(d=a.group({class:`apexcharts-series-markers apexcharts-series-${r.config.chart.type}`}),d.attr(`clip-path`,`url(#gridRectMarkerMask${r.globals.cuid})`),this.markers.setupMarkerDelegation(d),u.add(d),this._elPointsWrap=d,this._elPointsWrapParent=u,this._perSeries=this._buildPerSeriesCache(o,a)),Array.isArray(s.x))for(let e=0;e<s.x.length;e++){let n=t+1,i=!0;t===0&&e===0&&(n=0),t===0&&e===1&&(n=1);let u=r.globals.markers.size[o];if(c!==1/0){let e=r.config.plotOptions.bubble;u=r.seriesData.seriesZ[o][n],e.zScaling&&(u/=c),e.minBubbleRadius&&u<e.minBubbleRadius&&(u=e.minBubbleRadius),e.maxBubbleRadius&&u>e.maxBubbleRadius&&(u=e.maxBubbleRadius)}let f=s.x[e],p=s.y[e];if(u=u||0,(p===null||r.seriesData.series[o][n]===void 0)&&(i=!1),i){let e=this.drawPoint(f,p,u,o,n,t);d.add(e),a.kind===`canvas`&&(r.globals.pointsArray[o]===void 0&&(r.globals.pointsArray[o]=[]),r.globals.pointsArray[o][n]=[f,p])}}}_buildPerSeriesCache(e,t){var n;let r=this.w;return{realIndex:e,emit:t,isBubble:r.config.chart.type===`bubble`||r.globals.comboCharts&&r.config.series[e]&&r.config.series[e].type===`bubble`,canCacheConfig:!r.config.markers.discrete.length,markerConfig:null,fillCacheable:void 0,fillCircle:void 0,dropShadowEnabled:r.config.chart.dropShadow.enabled,doInitialAnim:this.initialAnim&&!r.globals.dataChanged&&!r.globals.resized,jitter:(n=r.config.plotOptions.scatter)==null?void 0:n.jitter,anim:null}}drawPoint(e,t,n,r,i,a){var o;let s=this.w,c=r,u=this.anim,d=this.filters,f=this.fill,p=this.markers,m=this._perSeries;(!m||m.realIndex!==r)&&(m=this._perSeries=this._buildPerSeriesCache(r,Oe(this.ctx,this.graphics)));let h=m.emit,g;m.canCacheConfig?(m.markerConfig||(m.markerConfig=p.getMarkerConfig({cssClass:`apexcharts-marker`,seriesIndex:c,dataPointIndex:i,radius:m.isBubble?n:null})),g=m.markerConfig,m.isBubble&&(g.pSize=n,g.pRadius=n)):g=p.getMarkerConfig({cssClass:`apexcharts-marker`,seriesIndex:c,dataPointIndex:i,radius:m.isBubble?n:null});let _=s.config.series[c].data[i],v;m.fillCircle===void 0?(v=f.fillPath({seriesNumber:r,dataPointIndex:i,color:g.pointFillColor,patternUnits:`objectBoundingBox`,value:s.seriesData.series[r][a]}),m.fillCacheable===void 0&&(m.fillCacheable=m.canCacheConfig&&f.getFillType(r)===`solid`&&typeof g.pointFillColor==`string`&&!!g.pointFillColor),m.fillCacheable&&!(_!=null&&_.fillColor)&&(m.fillCircle=v)):v=m.fillCircle;let y=h.drawMarker(e,t,g);_!=null&&_.fillColor&&(v=_.fillColor);let b=m.jitter;if(b!=null&&b.enabled&&b.distributed&&s.globals.colors.length){let e=Math.round((o=s.seriesData.seriesX[r])==null?void 0:o[i]);isNaN(e)||(v=s.globals.colors[e%s.globals.colors.length])}if(y.attr({fill:v}),m.dropShadowEnabled){let e=s.config.chart.dropShadow;d.dropShadow(y,e,r)}if(m.doInitialAnim){if(!m.anim){let e=s.config.chart.animations,t=s.globals.dataPoints||1,n=e.animateGradually,r=n&&n.enabled!==!1;m.anim={popSpeed:e.speed,baseDelay:r?Math.min(20,e.speed*.5/Math.max(1,t)):0}}let e=Te({style:m.anim.baseDelay>0?`sequential`:`none`,index:i,baseDelay:m.anim.baseDelay});u.animatePop(y,{speed:m.anim.popSpeed,delay:e,onComplete:()=>u.animationCompleted(y)})}else s.globals.animationEnded=!0;return y.attr({rel:i,j:i,index:r,"default-marker-size":g.pSize}),d.setSelectionFilter(y,r,i),y}centerTextInBubble(e){let t=this.w;return e+=parseInt(t.config.dataLabels.style.fontSize,10)/4,{y:e}}}const je=(e,t,n,r)=>{if(typeof e!=`function`)return e;let i=e({series:t.seriesData.series,seriesIndex:n,dataPointIndex:r,w:t});return Number.isFinite(i)?i:0};class DataLabels{constructor(e,t=null){this.w=e,this.ctx=t}dataLabelsCorrection(e,t,n,r,i,a,o){let s=this.w,c=new Graphics(this.w),u=!1,d=c.getTextRects(n,o),f=d.width,p=d.height;t<0&&(t=0),t>s.layout.gridHeight+p&&(t=s.layout.gridHeight+p/2),s.globals.dataLabelsRects[r]===void 0&&(s.globals.dataLabelsRects[r]=[]),s.globals.dataLabelsRects[r].push({x:e,y:t,width:f,height:p});let m=s.globals.dataLabelsRects[r].length-2,h=s.globals.lastDrawnDataLabelsIndexes[r]===void 0?0:s.globals.lastDrawnDataLabelsIndexes[r][s.globals.lastDrawnDataLabelsIndexes[r].length-1];if(s.globals.dataLabelsRects[r][m]!==void 0){let n=s.globals.dataLabelsRects[r][h];(e>n.x+n.width||t>n.y+n.height||t+p<n.y||e+f<n.x)&&(u=!0)}return(i===0||a)&&(u=!0),{x:e,y:t,textRects:d,drawnextLabel:u}}drawDataLabel({type:e,pos:t,i:n,j:r,isRangeStart:i,strokeWidth:a=2}){let o=this.w,s=new Graphics(this.w),c=o.config.dataLabels,u=0,d=0,f=r,p=null;if(o.globals.collapsedSeriesIndices.indexOf(n)!==-1||!c.enabled||!Array.isArray(t.x))return p;p=s.group({class:`apexcharts-data-labels`});for(let s=0;s<t.x.length;s++)if(r===1&&s===0&&(f=0),r===1&&s===1&&(f=1),u=t.x[s]+je(c.offsetX,o,n,f),d=t.y[s]+je(c.offsetY,o,n,f)+a,!isNaN(u)){let r=o.seriesData.series[n][f];e===`rangeArea`&&(r=i?o.rangeData.seriesRangeStart[n][f]:o.rangeData.seriesRangeEnd[n][f]);let a=``,c=e=>o.config.dataLabels.formatter(e,{seriesIndex:n,dataPointIndex:f,w:o});o.config.chart.type===`bubble`?(r=o.seriesData.seriesZ[n][f],a=c(r),d=t.y[s],d=new Scatter(this.w,this.ctx).centerTextInBubble(d).y):r!==void 0&&(a=c(r));let m=o.config.dataLabels.textAnchor;o.globals.isSlopeChart&&(m=f===0?`end`:f===o.config.series[n].data.length-1?`start`:`middle`),this.plotDataLabelsText({x:u,y:d,text:a,i:n,j:f,parent:p,offsetCorrection:!0,dataLabelsConfig:o.config.dataLabels,textAnchor:m})}return p}plotDataLabelsText(e){let t=this.w,n=new Graphics(this.w),{x:r,y:i,i:a,j:o,text:s,textAnchor:c,fontSize:u,parent:d,dataLabelsConfig:f,color:p,alwaysDrawDataLabel:m,offsetCorrection:h,className:g,seriesIndex:_=a,dataPointIndex:v=o}=e,y=null;if(Array.isArray(t.config.dataLabels.enabledOnSeries)&&t.config.dataLabels.enabledOnSeries.indexOf(a)<0)return y;let b={x:r,y:i,drawnextLabel:!0,textRects:null};if(h&&(b=this.dataLabelsCorrection(r,i,s,a,o,m,parseInt(f.style.fontSize,10).toString())),t.interact.zoomed||(r=b.x,i=b.y),b.textRects){let e=t.globals.barPadForNumericAxis||0;(r<-(e+20)-b.textRects.width||r>t.layout.gridWidth+b.textRects.width+e+30)&&(s=``)}let x=t.globals.dataLabels.style.colors[a];((t.config.chart.type===`bar`||t.config.chart.type===`rangeBar`)&&t.config.plotOptions.bar.distributed||t.config.dataLabels.distributed)&&(x=t.globals.dataLabels.style.colors[o]),typeof x==`function`&&(x=x({series:t.seriesData.series,seriesIndex:a,dataPointIndex:o,w:t})),p&&(x=p);let S=t.config.chart.type===`bar`||t.config.chart.type===`rangeBar`,C=S?0:je(f.offsetX,t,_,v),w=S?0:je(f.offsetY,t,_,v),T=C,E=w;if(t.globals.isSlopeChart&&(o!==0&&(T=C*-2+5),o!==0&&o!==t.config.series[a].data.length-1&&(T=0)),b.drawnextLabel){if(c===`middle`&&r===t.layout.gridWidth&&(c=`end`),y=n.drawText({x:r+T,y:i+E,foreColor:x,textAnchor:c||f.textAnchor,text:s,fontSize:u||f.style.fontSize,fontFamily:f.style.fontFamily,fontWeight:f.style.fontWeight||`normal`}),y.attr({class:g||`apexcharts-datalabel`,cx:r,cy:i}),f.dropShadow.enabled){let e=f.dropShadow;new Filters(this.w).dropShadow(y,e)}d.add(y),Ce(y,r,t),t.globals.lastDrawnDataLabelsIndexes[a]===void 0&&(t.globals.lastDrawnDataLabelsIndexes[a]=[]),t.globals.lastDrawnDataLabelsIndexes[a].push(o)}return y}addBackgroundToDataLabel(e,t){let n=this.w,r=n.config.dataLabels.background,i=r.padding,a=r.padding/2,o=t.width,s=t.height,c=new Graphics(this.w).drawRect(t.x-i,t.y-a/2,o+i*2,s+a,r.borderRadius,n.config.chart.background===`transparent`||!n.config.chart.background?`#fff`:n.config.chart.background,r.opacity,r.borderWidth,r.borderColor);return r.dropShadow.enabled&&new Filters(this.w).dropShadow(c,r.dropShadow),c}dataLabelsBackground(){var e;let t=this.w;if(t.config.chart.type===`bubble`)return;let n=t.dom.baseEl.querySelectorAll(`.apexcharts-datalabels text`);for(let r=0;r<n.length;r++){let i=n[r],a=i.getBBox(),o=null;if(a.width&&a.height&&(o=this.addBackgroundToDataLabel(i,a)),o){(e=i.parentNode)==null||e.insertBefore(o.node,i);let n=t.config.dataLabels.background.backgroundColor||i.getAttribute(`fill`);t.config.chart.animations.enabled&&!t.globals.resized&&!t.globals.dataChanged?o.animate().attr({fill:n}):o.attr({fill:n}),i.setAttribute(`fill`,t.config.dataLabels.background.foreColor);let r=i.getAttribute(`cx`);r!==null&&Ce(o,parseFloat(r),t)}}}bringForward(){let e=this.w,t=e.dom.baseEl.querySelectorAll(`.apexcharts-datalabels`),n=e.dom.baseEl.querySelector(`.apexcharts-plot-series:last-child`);for(let e=0;e<t.length;e++)n&&n.insertBefore(t[e],n.nextSibling)}}class PerformanceCache{static invalidateAll(e){!e||!e.globals||(e.globals.cachedSelectors&&(e.globals.cachedSelectors={}),e.globals.domCache&&e.globals.domCache.clear(),e.globals.dimensionCache={})}static invalidateDimensions(e){!e||!e.globals||(e.globals.dimensionCache={})}static invalidateSelectors(e){!e||!e.globals||e.globals.cachedSelectors&&(e.globals.cachedSelectors={})}static getCachedSelector(e,t,n){return!e||!e.globals?n():(e.globals.cachedSelectors||(e.globals.cachedSelectors={}),e.globals.cachedSelectors[t]||(e.globals.cachedSelectors[t]=n()),e.globals.cachedSelectors[t])}static getCachedDimension(e,t,n,r=1e3){if(!e||!e.globals)return n();e.globals.dimensionCache||(e.globals.dimensionCache={});let i=e.globals.dimensionCache[t],a=Date.now();if(i&&i.lastUpdate&&a-i.lastUpdate<r)return i.value;let o=n();return e.globals.dimensionCache[t]={value:o,lastUpdate:a},o}static cacheDOMElement(e,t,n){!e||!e.globals||(e.globals.domCache||(e.globals.domCache=/* @__PURE__ */ new Map),e.globals.domCache.set(t,n))}static getCachedDOMElement(e,t){return!e||!e.globals||!e.globals.domCache?null:e.globals.domCache.get(t)||null}}class AxesUtils{constructor(e,{theme:t=null,timeScale:n=null}={}){this.w=e,this.theme=t,this.timeScale=n}getLabel(e,t,n,r,i=[],a=`12px`,o=!0){let s=this.w,c=e[r]===void 0?``:e[r],u=c,d=s.formatters.xLabelFormatter,f=s.config.xaxis.labels.formatter,p=new Formatters(this.w),m=c;o&&(u=p.xLabelFormat(d,c,m,{i:r,dateFormatter:new DateTime(this.w).formatDate,w:s}),f!==void 0&&(u=f(c,e[r],{i:r,dateFormatter:new DateTime(this.w).formatDate,w:s}))),t.length>0?(n=t[r].position,u=t[r].value):s.config.xaxis.type===`datetime`&&f===void 0&&(u=``),u===void 0&&(u=``),u=Array.isArray(u)?u:u.toString();let h=new Graphics(this.w),g={};g=s.layout.rotateXLabels&&o?h.getTextRects(u,parseInt(a,10).toString(),null,`rotate(${s.config.xaxis.labels.rotate} 0 0)`,!1):h.getTextRects(u,parseInt(a,10).toString());let _=!s.config.xaxis.labels.showDuplicates&&this.timeScale;return!Array.isArray(u)&&(String(u)===`NaN`||i.indexOf(u)>=0&&_)&&(u=``),{x:n,text:u,textRect:g}}checkLabelBasedOnTickamount(e,t,n){let r=this.w,i=r.config.xaxis.tickAmount;return i===`dataPoints`&&(i=Math.round(r.layout.gridWidth/120)),i>n||e%Math.round(n/(i+1))===0||(t.text=``),t}checkForOverflowingLabels(e,t,n,r,i){let a=this.w;if(e===0&&a.globals.skipFirstTimelinelabel&&(t.text=``),e===n-1&&a.globals.skipLastTimelinelabel&&(t.text=``),a.config.xaxis.labels.hideOverlappingLabels&&r.length>0){let e=i[i.length-1];if(a.config.xaxis.labels.trim&&a.config.xaxis.type!==`datetime`)return t;t.x<e.textRect.width/(a.layout.rotateXLabels?Math.max(Math.abs(a.config.xaxis.labels.rotate),1)/12:1.01)+e.x&&(t.text=``)}return t}checkForReversedLabels(e,t){let n=this.w;return n.config.yaxis[e]&&n.config.yaxis[e].reversed&&t.reverse(),t}yAxisAllSeriesCollapsed(e){let t=this.w.globals;return!t.seriesYAxisMap[e].some(e=>t.collapsedSeriesIndices.indexOf(e)===-1)}translateYAxisIndex(e){let t=this.w,n=t.globals,r=t.config.yaxis;return t.seriesData.series.length>r.length||r.some(e=>Array.isArray(e.seriesName))?e:n.seriesYAxisReverseMap[e]}isYAxisHidden(e){let t=this.w,n=t.config.yaxis[e];if(!n.show||this.yAxisAllSeriesCollapsed(e))return!0;if(!n.showForNullSeries){let n=t.globals.seriesYAxisMap[e],r=new CoreUtils(this.w);return n.every(e=>r.isSeriesNull(e))}return!1}getYAxisForeColor(e,t){var n;let r=this.w;return Array.isArray(e)&&r.globals.yAxisScale[t]&&((n=this.theme)==null||n.pushExtraColors(e,r.globals.yAxisScale[t].result.length,!1)),e}drawYAxisTicks(e,t,n,r,i,a,o){let s=this.w,c=new Graphics(this.w),u=s.layout.translateY+s.config.yaxis[i].labels.offsetY;if(s.globals.isBarHorizontal?u=0:s.config.chart.type===`heatmap`&&(u+=a/2),r.show&&t>0){s.config.yaxis[i].opposite===!0&&(e+=r.width);for(let i=t;i>=0;i--){let t=c.drawLine(e+n.offsetX-r.width+r.offsetX,u+r.offsetY,e+n.offsetX+r.offsetX,u+r.offsetY,r.color);o.add(t),u+=a}}}}class XAxis{constructor(e,t,n){this.w=e,this.ctx=t,this.elgrid=n,this.axesUtils=new AxesUtils(e,{theme:t.theme,timeScale:t.timeScale}),this.xaxisLabels=e.labelData.labels.slice(),e.labelData.timescaleLabels.length>0&&!e.globals.isBarHorizontal&&(this.xaxisLabels=e.labelData.timescaleLabels.slice()),e.config.xaxis.overwriteCategories&&(this.xaxisLabels=e.config.xaxis.overwriteCategories),this.drawnLabels=[],this.drawnLabelsRects=[],e.config.xaxis.position===`top`?this.offY=0:this.offY=e.layout.gridHeight,this.offY+=e.config.xaxis.axisBorder.offsetY,this.isCategoryBarHorizontal=e.config.chart.type===`bar`&&e.config.plotOptions.bar.horizontal,this.xaxisFontSize=e.config.xaxis.labels.style.fontSize,this.xaxisFontFamily=e.config.xaxis.labels.style.fontFamily,this.xaxisForeColors=e.config.xaxis.labels.style.colors,this.xaxisBorderWidth=e.config.xaxis.axisBorder.width,this.isCategoryBarHorizontal&&(this.xaxisBorderWidth=e.config.yaxis[0].axisBorder.width.toString()),String(this.xaxisBorderWidth).indexOf(`%`)>-1?this.xaxisBorderWidth=e.layout.gridWidth*parseInt(this.xaxisBorderWidth,10)/100:this.xaxisBorderWidth=parseInt(this.xaxisBorderWidth,10),this.xaxisBorderHeight=e.config.xaxis.axisBorder.height,this.yaxis=e.config.yaxis[0]}drawXaxis(){let e=this.w,t=new Graphics(this.w),n=t.group({class:`apexcharts-xaxis`,transform:`translate(${e.config.xaxis.offsetX}, ${e.config.xaxis.offsetY})`}),r=t.group({class:`apexcharts-xaxis-texts-g`,transform:`translate(${e.layout.translateXAxisX}, ${e.layout.translateXAxisY})`});n.add(r);let i=[];for(let e=0;e<this.xaxisLabels.length;e++)i.push(this.xaxisLabels[e]);if(this.drawXAxisLabelAndGroup(!0,t,r,i,e.axisFlags.isXNumeric,(e,t)=>t),e.labelData.hasXaxisGroups){let n=e.labelData.groups;i=[];for(let e=0;e<n.length;e++)i.push(n[e].title);let a={};e.config.xaxis.group.style&&(a.xaxisFontSize=e.config.xaxis.group.style.fontSize,a.xaxisFontFamily=e.config.xaxis.group.style.fontFamily,a.xaxisForeColors=e.config.xaxis.group.style.colors,a.fontWeight=e.config.xaxis.group.style.fontWeight,a.cssClass=e.config.xaxis.group.style.cssClass),this.drawXAxisLabelAndGroup(!1,t,r,i,!1,(e,t)=>n[e].cols*t,a)}if(e.config.xaxis.title.text!==void 0){let r=t.group({class:`apexcharts-xaxis-title`}),i=t.drawText({x:e.layout.gridWidth/2+e.config.xaxis.title.offsetX,y:this.offY+parseFloat(this.xaxisFontSize)+(e.config.xaxis.position===`bottom`?e.layout.xAxisLabelsHeight:-e.layout.xAxisLabelsHeight-10)+e.config.xaxis.title.offsetY,text:e.config.xaxis.title.text,textAnchor:`middle`,fontSize:e.config.xaxis.title.style.fontSize,fontFamily:e.config.xaxis.title.style.fontFamily,fontWeight:e.config.xaxis.title.style.fontWeight,foreColor:e.config.xaxis.title.style.color,cssClass:`apexcharts-xaxis-title-text `+e.config.xaxis.title.style.cssClass});r.add(i),n.add(r)}if(e.config.xaxis.axisBorder.show){let r=e.globals.barPadForNumericAxis,i=t.drawLine(e.globals.padHorizontal+e.config.xaxis.axisBorder.offsetX-r,this.offY,this.xaxisBorderWidth+r,this.offY,e.config.xaxis.axisBorder.color,0,this.xaxisBorderHeight);this.elgrid&&this.elgrid.elGridBorders&&e.config.grid.show?this.elgrid.elGridBorders.add(i):n.add(i)}return n}drawXAxisLabelAndGroup(e,t,n,r,i,a,o={}){var s,c;let u=[],d=[],f=this.w,p=o.xaxisFontSize||this.xaxisFontSize,m=o.xaxisFontFamily||this.xaxisFontFamily,h=o.xaxisForeColors||this.xaxisForeColors,g=o.fontWeight||f.config.xaxis.labels.style.fontWeight,_=o.cssClass||f.config.xaxis.labels.style.cssClass,v,y=f.globals.padHorizontal,b=r.length,x=f.config.xaxis.type===`category`?f.globals.dataPoints:b;if(x===0&&b>x&&(x=b),i){let e=Math.max(Number(f.config.xaxis.tickAmount)||1,x>1?x-1:x);v=f.layout.gridWidth/Math.min(e,b-1),y=y+a(0,v)/2+f.config.xaxis.labels.offsetX}else v=f.layout.gridWidth/x,y=y+a(0,v)+f.config.xaxis.labels.offsetX;for(let i=0;i<=b-1;i++){let o=y-a(i,v)/2+f.config.xaxis.labels.offsetX;i===0&&b===1&&v/2===y&&x===1&&(o=f.layout.gridWidth/2);let S=this.axesUtils.getLabel(r,f.labelData.timescaleLabels,o,i,u,p,e),C=28;f.layout.rotateXLabels&&e&&(C=22),f.config.xaxis.title.text&&f.config.xaxis.position===`top`&&(C+=parseFloat(f.config.xaxis.title.style.fontSize)+2),e||(C=C+parseFloat(p)+(f.layout.xAxisLabelsHeight-f.layout.xAxisGroupLabelsHeight)+(f.layout.rotateXLabels?10:0)),S=f.config.xaxis.tickAmount!==void 0&&f.config.xaxis.tickAmount!==`dataPoints`&&f.config.xaxis.type!==`datetime`?this.axesUtils.checkLabelBasedOnTickamount(i,S,b):this.axesUtils.checkForOverflowingLabels(i,S,b,u,d);let w=()=>e&&f.config.xaxis.convertedCatToNumeric?h[f.globals.minX+i-1]:h[i],T=((c=(s=S.textRect)==null?void 0:s.width)==null?0:c)/2,E=S.x+T<0;if(f.config.xaxis.labels.show&&!E){let r=t.drawText({x:S.x,y:this.offY+f.config.xaxis.labels.offsetY+C-(f.config.xaxis.position===`top`?f.layout.xAxisHeight+f.config.xaxis.axisTicks.height-2:0),text:S.text,textAnchor:`middle`,fontWeight:g,fontSize:p,fontFamily:m,foreColor:Array.isArray(h)?w():h,isPlainText:!1,cssClass:(e?`apexcharts-xaxis-label `:`apexcharts-xaxis-group-label `)+_});if(n.add(r),r.on(`click`,e=>{if(typeof f.config.chart.events.xAxisLabelClick==`function`){let t=Object.assign({},f,{labelIndex:i});f.config.chart.events.xAxisLabelClick(e,this.ctx,t)}}),e){let e=BrowserAPIs.createElementNS(P,`title`);e.textContent=Array.isArray(S.text)?S.text.join(` `):S.text,r.node.appendChild(e),S.text!==``&&(u.push(S.text),d.push(S))}}i<b-1&&(y+=a(i+1,v))}}drawXaxisInversed(e){let t=this.w,n=new Graphics(this.w),r=t.config.yaxis[0].opposite?t.globals.translateYAxisX[e]:0,i=n.group({class:`apexcharts-yaxis apexcharts-xaxis-inversed`,rel:e}),a=n.group({class:`apexcharts-yaxis-texts-g apexcharts-xaxis-inversed-texts-g`,transform:`translate(`+r+`, 0)`});i.add(a);let o=[];if(t.config.yaxis[e].show)for(let e=0;e<this.xaxisLabels.length;e++)o.push(this.xaxisLabels[e]);let s=t.layout.gridHeight/o.length,c=-(s/2.2),u=t.formatters.yLabelFormatters[0],d=t.config.yaxis[0].labels;if(d.show)for(let r=0;r<=o.length-1;r++){let i=o[r]===void 0?``:o[r];i=u(i,{seriesIndex:e,dataPointIndex:r,w:t});let f=this.axesUtils.getYAxisForeColor(d.style.colors,e),p=()=>Array.isArray(f)?f[r]:f,m=0;Array.isArray(i)&&(m=i.length/2*parseInt(d.style.fontSize,10));let h=d.offsetX-15,g=`end`;this.yaxis.opposite&&(g=`start`),t.config.yaxis[0].labels.align===`left`?(h=d.offsetX,g=`start`):t.config.yaxis[0].labels.align===`center`?(h=d.offsetX,g=`middle`):t.config.yaxis[0].labels.align===`right`&&(g=`end`);let _=n.drawText({x:h,y:c+s+d.offsetY-m,text:i,textAnchor:g,foreColor:p(),fontSize:d.style.fontSize,fontFamily:d.style.fontFamily,fontWeight:d.style.fontWeight,isPlainText:!1,cssClass:`apexcharts-yaxis-label `+d.style.cssClass,maxWidth:d.maxWidth});a.add(_),_.on(`click`,e=>{if(typeof t.config.chart.events.xAxisLabelClick==`function`){let n=Object.assign({},t,{labelIndex:r});t.config.chart.events.xAxisLabelClick(e,this.ctx,n)}});let v=BrowserAPIs.createElementNS(P,`title`);if(v.textContent=Array.isArray(i)?i.join(` `):i,_.node.appendChild(v),t.config.yaxis[e].labels.rotate!==0){let r=n.rotateAroundCenter(_.node);_.node.setAttribute(`transform`,`rotate(${t.config.yaxis[e].labels.rotate} 0 ${r.y})`)}c+=s}if(t.config.yaxis[0].title.text!==void 0){let e=n.group({class:`apexcharts-yaxis-title apexcharts-xaxis-title-inversed`,transform:`translate(`+r+`, 0)`}),a=n.drawText({x:t.config.yaxis[0].title.offsetX,y:t.layout.gridHeight/2+t.config.yaxis[0].title.offsetY,text:t.config.yaxis[0].title.text,textAnchor:`middle`,foreColor:t.config.yaxis[0].title.style.color,fontSize:t.config.yaxis[0].title.style.fontSize,fontWeight:t.config.yaxis[0].title.style.fontWeight,fontFamily:t.config.yaxis[0].title.style.fontFamily,cssClass:`apexcharts-yaxis-title-text `+t.config.yaxis[0].title.style.cssClass});e.add(a),i.add(e)}let f=0;this.isCategoryBarHorizontal&&t.config.yaxis[0].opposite&&(f=t.layout.gridWidth);let p=t.config.xaxis.axisBorder;if(p.show){let e=n.drawLine(t.globals.padHorizontal+p.offsetX+f,1+p.offsetY,t.globals.padHorizontal+p.offsetX+f,t.layout.gridHeight+p.offsetY,p.color,0);this.elgrid&&this.elgrid.elGridBorders&&t.config.grid.show?this.elgrid.elGridBorders.add(e):i.add(e)}return t.config.yaxis[0].axisTicks.show&&this.axesUtils.drawYAxisTicks(f,o.length,t.config.yaxis[0].axisBorder,t.config.yaxis[0].axisTicks,0,s,i),i}drawXaxisTicks(e,t,n){let r=this.w,i=e;if(e<0||e-2>r.layout.gridWidth)return;let a=this.offY+r.config.xaxis.axisTicks.offsetY;if(t=t+a+r.config.xaxis.axisTicks.height,r.config.xaxis.position===`top`&&(t=a-r.config.xaxis.axisTicks.height),r.config.xaxis.axisTicks.show){let o=new Graphics(this.w).drawLine(e+r.config.xaxis.axisTicks.offsetX,a+r.config.xaxis.offsetY,i+r.config.xaxis.axisTicks.offsetX,t+r.config.xaxis.offsetY,r.config.xaxis.axisTicks.color);n.add(o),o.node.classList.add(`apexcharts-xaxis-tick`)}}getXAxisTicksPositions(){let e=this.w,t=[],n=this.xaxisLabels.length,r=e.globals.padHorizontal;if(e.labelData.timescaleLabels.length>0)for(let e=0;e<n;e++)r=this.xaxisLabels[e].position,t.push(r);else{let i=n;for(let n=0;n<i;n++){let n=i;e.axisFlags.isXNumeric&&e.config.chart.type!==`bar`&&--n,r+=e.layout.gridWidth/n,t.push(r)}}return t}xAxisLabelCorrections(){var e,t,n;let r=this.w,i=new Graphics(this.w),a=r.dom.baseEl.querySelector(`.apexcharts-xaxis-texts-g`),o=r.dom.baseEl.querySelectorAll(`.apexcharts-xaxis-texts-g text:not(.apexcharts-xaxis-group-label)`),s=r.dom.baseEl.querySelectorAll(`.apexcharts-yaxis-inversed text`),c=r.dom.baseEl.querySelectorAll(`.apexcharts-xaxis-inversed-texts-g text tspan`);if(r.layout.rotateXLabels||r.config.xaxis.labels.rotateAlways)for(let e=0;e<o.length;e++){let t=i.rotateAroundCenter(o[e]);--t.y,t.x+=1,o[e].setAttribute(`transform`,`rotate(${r.config.xaxis.labels.rotate} ${t.x} ${t.y})`),o[e].setAttribute(`text-anchor`,`end`),a==null||a.setAttribute(`transform`,`translate(0, -10)`);let n=o[e].childNodes;r.config.xaxis.labels.trim&&Array.prototype.forEach.call(n,e=>{i.placeTextWithEllipsis(e,e.textContent,r.layout.xAxisLabelsHeight-(r.config.legend.position===`bottom`?20:10))})}else{let e=r.layout.gridWidth/(r.labelData.labels.length+1);for(let t=0;t<o.length;t++){let n=o[t].childNodes;r.config.xaxis.labels.trim&&r.config.xaxis.type!==`datetime`&&Array.prototype.forEach.call(n,t=>{i.placeTextWithEllipsis(t,t.textContent,e)})}}if(s.length>0){let a=s[s.length-1].getBBox(),o=s[0].getBBox();a.x<-20&&((e=s[s.length-1].parentNode)==null||e.removeChild(s[s.length-1])),o.x+o.width>r.layout.gridWidth&&!r.globals.isBarHorizontal&&((t=s[0].parentNode)==null||t.removeChild(s[0]));for(let e=0;e<c.length;e++)i.placeTextWithEllipsis(c[e],(n=c[e].textContent)==null?``:n,r.config.yaxis[0].labels.maxWidth-(r.config.yaxis[0].title.text?parseFloat(r.config.yaxis[0].title.style.fontSize)*2:0)-15)}}}class Grid{constructor(e,t){this.w=e,this.ctx=t,this.xaxisLabels=e.labelData.labels.slice(),this.axesUtils=new AxesUtils(t.w,{theme:t.theme,timeScale:t.timeScale}),this.isRangeBar=e.rangeData.seriesRange.length&&e.globals.isBarHorizontal,e.labelData.timescaleLabels.length>0&&(this.xaxisLabels=e.labelData.timescaleLabels.slice())}drawGridArea(e=null){let t=this.w,n=new Graphics(this.w);e||(e=n.group({class:`apexcharts-grid`}));let r=n.drawLine(t.globals.padHorizontal,1,t.globals.padHorizontal,t.layout.gridHeight,`transparent`),i=n.drawLine(t.globals.padHorizontal,t.layout.gridHeight,t.layout.gridWidth,t.layout.gridHeight,`transparent`);return e.add(i),e.add(r),e}drawGrid(){if(this.w.globals.axisCharts){let e=this.renderGrid();return this.drawGridArea(e.el),e}return null}createGridMask(){let e=this.w,t=e.globals,n=new Graphics(this.w),r=Array.isArray(e.config.stroke.width)?Math.max(...e.config.stroke.width):e.config.stroke.width,i=e=>{let t=BrowserAPIs.createElementNS(P,`clipPath`);return t.setAttribute(`id`,e),t};e.dom.elGridRectMask=i(`gridRectMask${t.cuid}`),e.dom.elGridRectBarMask=i(`gridRectBarMask${t.cuid}`),e.dom.elGridRectMarkerMask=i(`gridRectMarkerMask${t.cuid}`),e.dom.elForecastMask=i(`forecastMask${t.cuid}`),e.dom.elNonForecastMask=i(`nonForecastMask${t.cuid}`);let a=[`bar`,`rangeBar`,`candlestick`,`boxPlot`,`violin`].includes(e.config.chart.type)||e.globals.comboBarCount>0,o=0,s=0;a&&e.axisFlags.isXNumeric&&!e.globals.isBarHorizontal&&(o=Math.max(e.layout.gridPad.left,t.barPadForNumericAxis),s=Math.max(e.layout.gridPad.right,t.barPadForNumericAxis)),e.dom.elGridRect=n.drawRect(-r/2-2,-r/2-2,e.layout.gridWidth+r+4,e.layout.gridHeight+r+4,0,`#fff`),e.dom.elGridRectBar=n.drawRect(-r/2-o-2,-r/2-2,e.layout.gridWidth+r+s+o+4,e.layout.gridHeight+r+4,0,`#fff`);let c=e.globals.markers.largestSize;e.dom.elGridRectMarker=n.drawRect(Math.min(-r/2-o-2,-c),-c,e.layout.gridWidth+Math.max(r+s+o+4,c*2),e.layout.gridHeight+c*2,0,`#fff`),e.dom.elGridRectMask.appendChild(e.dom.elGridRect.node),e.dom.elGridRectBarMask.appendChild(e.dom.elGridRectBar.node),e.dom.elGridRectMarkerMask.appendChild(e.dom.elGridRectMarker.node);let u=e.dom.elDefs.node;u.appendChild(e.dom.elGridRectMask),u.appendChild(e.dom.elGridRectBarMask),u.appendChild(e.dom.elGridRectMarkerMask),u.appendChild(e.dom.elForecastMask),u.appendChild(e.dom.elNonForecastMask)}_drawGridLines({i:e,x1:t,y1:n,x2:r,y2:i,xCount:a,parent:o}){let s=this.w,c=()=>!(e===0&&s.globals.skipFirstTimelinelabel||e===a-1&&s.globals.skipLastTimelinelabel&&!s.config.xaxis.labels.formatter||s.config.chart.type===`radar`);if(c()){s.config.grid.xaxis.lines.show&&this._drawGridLine({i:e,x1:t,y1:n,x2:r,y2:i,xCount:a,parent:o});let c=0;if(s.labelData.hasXaxisGroups&&s.config.xaxis.tickPlacement===`between`){let t=s.labelData.groups;if(t){let n=0;for(let r=0;n<e&&r<t.length;r++)n+=t[r].cols;n===e&&(c=s.layout.xAxisLabelsHeight*.6)}}new XAxis(this.w,this.ctx).drawXaxisTicks(t,c,s.dom.elGraphical)}}_drawGridLine({i:e,x1:t,y1:n,x2:r,y2:i,xCount:a,parent:o}){let s=this.w,c=o.node.classList.contains(`apexcharts-gridlines-horizontal`),u=s.globals.barPadForNumericAxis,d=n===0&&i===0||t===0&&r===0||n===s.layout.gridHeight&&i===s.layout.gridHeight||s.globals.isBarHorizontal&&(e===0||e===a-1),f=new Graphics(this.w).drawLine(t-(c?u:0),n,r+(c?u:0),i,s.config.grid.borderColor,s.config.grid.strokeDashArray);f.node.classList.add(`apexcharts-gridline`),d&&s.config.grid.show?this.elGridBorders.add(f):o.add(f)}_drawGridBandRect({c:e,x1:t,y1:n,x2:r,y2:i,type:a}){let o=this.w,s=new Graphics(this.w),c=o.globals.barPadForNumericAxis,u=o.config.grid[a].colors[e],d=s.drawRect(t-(a===`row`?c:0),n,r+(a===`row`?c*2:0),i,0,u,o.config.grid[a].opacity);this.elg.add(d),d.attr(`clip-path`,`url(#gridRectMask${o.globals.cuid})`),d.node.classList.add(`apexcharts-grid-${a}`)}_drawXYLines({xCount:e,tickAmount:t}){var n;let r=this.w,i=({xC:t,x1:n,y1:i,x2:a,y2:o})=>{for(let s=0;s<t;s++)n=this.xaxisLabels[s].position,a=this.xaxisLabels[s].position,!(n<0||n-2>r.layout.gridWidth)&&this._drawGridLines({i:s,x1:n,y1:i,x2:a,y2:o,xCount:e,parent:this.elgridLinesV})},a=({xC:t,x1:n,y1:i,x2:a,y2:o})=>{for(let s=0;s<t+ +!r.axisFlags.isXNumeric;s++)s===0&&t===1&&r.globals.dataPoints===1&&(n=r.layout.gridWidth/2,a=n),this._drawGridLines({i:s,x1:n,y1:i,x2:a,y2:o,xCount:e,parent:this.elgridLinesV}),n+=r.layout.gridWidth/(r.axisFlags.isXNumeric?t-1:t),a=n};if(r.config.grid.xaxis.lines.show||r.config.xaxis.axisTicks.show){let t=r.globals.padHorizontal,o=0,s,c=r.layout.gridHeight;r.labelData.timescaleLabels.length?i({xC:e,x1:t,y1:0,x2:void 0,y2:c}):(r.axisFlags.isXNumeric&&(e=(n=r.globals.xAxisScale)==null?void 0:n.result.length),a({xC:e,x1:t,y1:0,x2:void 0,y2:c}))}if(r.config.grid.yaxis.lines.show){let e=0,n=0,i=0,a=r.layout.gridWidth,o=t+1;this.isRangeBar&&(o=r.labelData.labels.length);for(let e=0;e<o+ +!!this.isRangeBar;e++)this._drawGridLine({i:e,xCount:o+ +!!this.isRangeBar,x1:0,y1:n,x2:a,y2:i,parent:this.elgridLinesH}),n+=r.layout.gridHeight/(this.isRangeBar?o:t),i=n}}_drawInvertedXYLines({xCount:e}){let t=this.w;if(t.config.grid.xaxis.lines.show||t.config.xaxis.axisTicks.show){let n=t.globals.padHorizontal,r=0,i,a=t.layout.gridHeight;for(let r=0;r<e+1;r++)t.config.grid.xaxis.lines.show&&this._drawGridLine({i:r,xCount:e+1,x1:n,y1:0,x2:i,y2:a,parent:this.elgridLinesV}),new XAxis(this.w,this.ctx).drawXaxisTicks(n,0,t.dom.elGraphical),n+=t.layout.gridWidth/e,i=n}if(t.config.grid.yaxis.lines.show){let e=0,n=0,r=0,i=t.layout.gridWidth;for(let e=0;e<t.globals.dataPoints+1;e++)this._drawGridLine({i:e,xCount:t.globals.dataPoints+1,x1:0,y1:n,x2:i,y2:r,parent:this.elgridLinesH}),n+=t.layout.gridHeight/t.globals.dataPoints,r=n}}renderGrid(){var e,t,n;let r=this.w,i=r.globals,a=new Graphics(this.w);this.elg=a.group({class:`apexcharts-grid`}),this.elgridLinesH=a.group({class:`apexcharts-gridlines-horizontal`}),this.elgridLinesV=a.group({class:`apexcharts-gridlines-vertical`}),this.elGridBorders=a.group({class:`apexcharts-grid-borders`}),this.elg.add(this.elgridLinesH),this.elg.add(this.elgridLinesV),r.config.grid.show||(this.elgridLinesV.hide(),this.elgridLinesH.hide(),this.elGridBorders.hide());let o=0;for(;o<i.seriesYAxisMap.length&&i.ignoreYAxisIndexes.includes(o);)o++;o===i.seriesYAxisMap.length&&(o=0);let s=i.yAxisScale[o].result.length-1,c;return!i.isBarHorizontal||this.isRangeBar?(c=this.xaxisLabels.length,this.isRangeBar&&(s=r.labelData.labels.length,r.config.xaxis.tickAmount&&r.config.xaxis.labels.formatter&&(c=r.config.xaxis.tickAmount),((n=(t=(e=i.yAxisScale)==null?void 0:e[o])==null?void 0:t.result)==null?void 0:n.length)>0&&r.config.xaxis.type!==`datetime`&&(c=i.yAxisScale[o].result.length-1)),this._drawXYLines({xCount:c,tickAmount:s})):(c=s,s=i.xTickAmount,this._drawInvertedXYLines({xCount:c,tickAmount:s})),this.drawGridBands(c,s),{el:this.elg,elGridBorders:this.elGridBorders,xAxisTickWidth:r.layout.gridWidth/c}}drawGridBands(e,t){var n,r,i,a,o;let s=this.w,c=(e,n,r,i,a,o)=>{for(let c=0,u=0;c<n;c++,u++)u>=s.config.grid[e].colors.length&&(u=0),this._drawGridBandRect({c:u,x1:r,y1:i,x2:a,y2:o,type:e}),i+=s.layout.gridHeight/t};if(((n=s.config.grid.row.colors)==null?void 0:n.length)>0&&c(`row`,t,0,0,s.layout.gridWidth,s.layout.gridHeight/t),((r=s.config.grid.column.colors)==null?void 0:r.length)>0){let t=!s.globals.isBarHorizontal&&s.config.xaxis.tickPlacement===`on`&&(s.config.xaxis.type===`category`||s.config.xaxis.convertedCatToNumeric)?e-1:e;s.axisFlags.isXNumeric&&(t=((a=(i=s.globals.xAxisScale)==null?void 0:i.result.length)==null?1:a)-1);let n=s.globals.padHorizontal,r=0,c=s.globals.padHorizontal+s.layout.gridWidth/t,u=s.layout.gridHeight;for(let r=0,i=0;r<e;r++,i++)i>=s.config.grid.column.colors.length&&(i=0),s.config.xaxis.type===`datetime`&&(n=this.xaxisLabels[r].position,c=(((o=this.xaxisLabels[r+1])==null?void 0:o.position)||s.layout.gridWidth)-this.xaxisLabels[r].position),this._drawGridBandRect({c:i,x1:n,y1:0,x2:c,y2:u,type:`column`}),n+=s.layout.gridWidth/t}}}class Scales{constructor(e){this.w=e,this.coreUtils=new CoreUtils(this.w)}niceScale(e,t,n=0){let r=1e-11,i=this.w,a=i.globals,o,s,c,u;a.isBarHorizontal?(o=i.config.xaxis,s=Math.max((a.svgWidth-100)/25,2)):(o=i.config.yaxis[n],s=Math.max((a.svgHeight-100)/15,2)),_.isNumber(s)||(s=10),c=o.min!==void 0&&o.min!==null,u=o.max!==void 0&&o.max!==null;let d=o.stepSize!==void 0&&o.stepSize!==null,f=o.tickAmount!==void 0&&o.tickAmount!==null,p=f?o.tickAmount:N[Math.min(Math.round(s/2),N.length-1)];if(a.isMultipleYAxis&&!f&&a.multiAxisTickAmount>0&&(p=a.multiAxisTickAmount,f=!0),p=p===`dataPoints`?a.dataPoints-1:Math.abs(Math.round(p)),(e===Number.MIN_VALUE&&t===0||!_.isNumber(e)&&!_.isNumber(t)||e===Number.MIN_VALUE&&t===-Number.MAX_VALUE)&&(e=_.isNumber(o.min)?o.min:0,t=_.isNumber(o.max)?o.max:e+p,a.allSeriesCollapsed=!1),e>t){console.warn(`axis.min cannot be greater than axis.max: swapping min and max`);let n=t;t=e,e=n}else e===t&&(e=e===0?0:e-1,t=t===0?2:t+1);let m=[];p<1&&(p=1);let h=p,g=Math.abs(t-e),v=.15;!c&&e>0&&e/g<v&&(e=0,c=!0),!u&&t<0&&-t/g<v&&(t=0,u=!0),g=Math.abs(t-e);let y=g/h,b=y,x=Math.floor(Math.log10(b)),S=10**x,C=Math.ceil(b/S);if(C=M[a.yValueDecimal===0?0:1][C],b=C*S,y=b,a.isBarHorizontal&&o.stepSize&&o.type!==`datetime`?(y=o.stepSize,d=!0):d&&(y=o.stepSize),d&&o.forceNiceScale&&(y*=10**(x-Math.floor(Math.log10(y)))),c&&u){let e=g/h;if(f)if(d)if(_.mod(g,y)!=0){let t=_.getGCD(y,e);y=e/t<10?t:e}else _.mod(y,e)==0?y=e:(e=y,f=!1);else y=e;else if(d)_.mod(g,y)==0?e=y:y=e;else if(_.mod(g,y)==0)e=y;else{h=Math.ceil(g/y),e=g/h;let t=_.getGCD(g,y);g/t<s&&(e=t),y=e}h=Math.round(g/y)}else{if(!c&&!u)if(a.isMultipleYAxis&&f){let n=y*Math.floor(e/y),r=n+y*h;r<t&&(y*=2),e=n,r=t,t=e+y*h,g=Math.abs(t-e),e>0&&e<Math.abs(r-t)&&(e=0,t=y*h),t<0&&-t<Math.abs(n-e)&&(t=0,e=-y*h)}else e=y*Math.floor(e/y),t=y*Math.ceil(t/y);else if(u)if(f)e=t-y*h;else{let n=e;e=y*Math.floor(e/y),Math.abs(t-e)/_.getGCD(g,y)>s&&(e=t-y*p,e+=y*Math.floor((n-e)/y))}else if(c)if(f)t=e+y*h;else{let n=t;t=y*Math.ceil(t/y),Math.abs(t-e)/_.getGCD(g,y)>s&&(t=e+y*p,t+=y*Math.ceil((n-t)/y))}g=Math.abs(t-e),y=_.getGCD(g,y),h=Math.round(g/y)}if(!f&&!(c||u)&&(h=Math.ceil((g-r)/(y+r)),h>16&&_.getPrimeFactors(h).length<2&&h++),!f&&o.forceNiceScale&&a.yValueDecimal===0&&h>g&&(h=g,y=Math.round(g/h)),h>s&&(!(f||d)||o.forceNiceScale)){let e=_.getPrimeFactors(h),t=e.length-1,n=h;reduceLoop:for(var w=0;w<t;w++)for(var T=0;T<=t-w;T++){let r=Math.min(T+w,t),i=n,a=1;for(var E=T;E<=r;E++)a*=e[E];if(i/=a,i<s){n=i;break reduceLoop}}y=n===h?g:g/n,h=Math.round(g/y)}a.isMultipleYAxis&&a.multiAxisTickAmount==0&&a.ignoreYAxisIndexes.indexOf(n)<0&&(a.multiAxisTickAmount=h);let D=e-y,O=y*r;do D+=y,m.push(_.stripNumber(D,7));while(t-D>O);return{result:m,niceMin:m[0],niceMax:m[m.length-1]}}linearScale(e,t,n=10,r=0,i=void 0){let a=Math.abs(t-e),o=[];if(e===t)return o=[e],{result:o,niceMin:o[0],niceMax:o[o.length-1]};n=this._adjustTicksForSmallRange(n,r,a),n===`dataPoints`&&(n=this.w.globals.dataPoints-1);let s=n;i||(i=a/s);let c=2;if(i!==0&&isFinite(i)){let e=10**Math.max(2,-Math.floor(Math.log10(Math.abs(i)))+2);i=Math.round((i+2**-52)*e)/e}let u=n===Number.MAX_VALUE?5:s;n===Number.MAX_VALUE&&(i=1);let d=e;for(;u>=0;)o.push(d),d=_.preciseAddition(d,i),--u;return{result:o,niceMin:o[0],niceMax:o[o.length-1]}}_resolveLogTickAmount(e){let t=e.tickAmount;return t===`dataPoints`&&(t=this.w.globals.dataPoints-1),_.isNumber(t)&&t>=1?Number(t):null}_thinToTickAmount(e,t){if(t===null||!_.isNumber(t)||t<1)return e;let n=t+1;if(e.length<=n)return e;let r=e.length-1,i=null;for(let e=1;e<=r;e++){if(r%e!==0)continue;let t=r/e+1;t>n||(i===null||t>i.count)&&(i={stride:e,count:t})}if(!i)return[e[0],e[e.length-1]];let a=[];for(let t=0;t<e.length;t+=i.stride)a.push(e[t]);return a}logarithmicScaleNice(e,t,n,r=null){t<=0&&(t=Math.max(e,n)),e<=0&&(e=Math.min(t,n));let i=[],a=Math.ceil(Math.log(t)/Math.log(n)+1),o=Math.floor(Math.log(e)/Math.log(n));for(let e=o;e<a;e++)i.push(n**+e);let s=this._thinToTickAmount(i,r);return{result:s,niceMin:s[0],niceMax:s[s.length-1]}}_logDomainSpan(e,t,n){return n||(n=10),n<=1||(t<=0&&(t=Math.max(e,n)),e<=0&&(e=Math.min(t,n)),e<=0||t<=0)?0:Math.abs(Math.log(t)/Math.log(n)-Math.log(e)/Math.log(n))}logarithmicScale(e,t,n,r=null){t<=0&&(t=Math.max(e,n)),e<=0&&(e=Math.min(t,n));let i=[],a=Math.log(t)/Math.log(n),o=Math.log(e)/Math.log(n),s=a-o,c=r===null?Math.max(1,Math.round(s)):r,u=s/c;for(let e=0,t=o;e<c;e++,t+=u)i.push(n**+t);return i.push(n**+a),{result:i,niceMin:e,niceMax:t}}_adjustTicksForSmallRange(e,t,n){let r=e;if(t!==void 0&&this.w.config.yaxis[t].labels.formatter&&this.w.config.yaxis[t].tickAmount===void 0){let e=Number(this.w.config.yaxis[t].labels.formatter(1));_.isNumber(e)&&this.w.globals.yValueDecimal===0&&(r=Math.ceil(n))}return r<e?r:e}setYScaleForIndex(e,t,n){let r=this.w.globals,i=this.w.config,a=r.isBarHorizontal?i.xaxis:i.yaxis[e];r.yAxisScale[e]===void 0&&(r.yAxisScale[e]=[]);let o=Math.abs(n-t),s=a.logarithmic&&this._logDomainSpan(t,n,a.logBase)>=1,c=a.logarithmic&&(s||o>5);if(a.logarithmic&&!c&&(r.invalidLogScale=!0),c){r.allSeriesCollapsed=!1;let i=this._resolveLogTickAmount(a);r.yAxisScale[e]=a.forceNiceScale?this.logarithmicScaleNice(t,n,a.logBase,i):this.logarithmicScale(t,n,a.logBase,i)}else n===-Number.MAX_VALUE||!_.isNumber(n)||t===Number.MAX_VALUE||!_.isNumber(t)?r.yAxisScale[e]=this.niceScale(Number.MIN_VALUE,0,e):(r.allSeriesCollapsed=!1,r.yAxisScale[e]=this.niceScale(t,n,e))}setXScale(e,t){let n=this.w,r=n.globals;if(t===-Number.MAX_VALUE||!_.isNumber(t))r.xAxisScale=this.linearScale(0,10,10);else{let i=r.xTickAmount;r.xAxisScale=this.linearScale(e,t,i,0,n.config.xaxis.max===void 0?n.config.xaxis.stepSize:void 0)}return r.xAxisScale}scaleMultipleYAxes(){let e=this.w.config,t=this.w.globals;this.coreUtils.setSeriesYAxisMappings();let n=t.seriesYAxisMap,r=t.minYArr,i=t.maxYArr,a=[],o=!t.isBarHorizontal;if(t.allSeriesCollapsed=!0,t.barGroups=[],n.forEach((n,s)=>{let c=[];if(n.forEach(t=>{var n;let r=(n=e.series[t])==null?void 0:n.group;c.indexOf(r)<0&&c.push(r)}),n.length>0){let u=Number.MAX_VALUE,d=-Number.MAX_VALUE,f=u,p=d,m,h;if(e.chart.stacked){let r=Array(t.dataPoints).fill(0),i=[],a=[],o=[];c.forEach(()=>{i.push(r.map(()=>Number.MIN_VALUE)),a.push(r.map(()=>Number.MIN_VALUE)),o.push(r.map(()=>Number.MIN_VALUE))});for(let r=0;r<n.length;r++){!m&&e.series[n[r]].type&&(m=e.series[n[r]].type);let u=n[r];h=e.series[u].group?e.series[u].group:`axis-${s.toString()}`,!(t.collapsedSeriesIndices.indexOf(u)<0&&t.ancillaryCollapsedSeriesIndices.indexOf(u)<0)||(t.allSeriesCollapsed=!1,c.forEach((t,n)=>{if(e.series[u].group===t)for(let e=0;e<this.w.seriesData.series[u].length;e++){let t=this.w.seriesData.series[u][e];t>=0?a[n][e]+=t:o[n][e]+=t,i[n][e]+=t,f=Math.min(f,t),p=Math.max(p,t)}})),(m===`bar`||m===`column`)&&t.barGroups.push(h)}m||(m=e.chart.type),m===`bar`||m===`column`?c.forEach((e,t)=>{u=Math.min(u,Math.min.apply(null,o[t])),d=Math.max(d,Math.max.apply(null,a[t]))}):(c.forEach((e,t)=>{f=Math.min(f,Math.min.apply(null,i[t])),p=Math.max(p,Math.max.apply(null,i[t]))}),u=f,d=p),u===Number.MIN_VALUE&&d===Number.MIN_VALUE&&(d=-Number.MAX_VALUE)}else for(let e=0;e<n.length;e++){let a=n[e];u=Math.min(u,r[a]),d=Math.max(d,i[a]),!(t.collapsedSeriesIndices.indexOf(a)<0&&t.ancillaryCollapsedSeriesIndices.indexOf(a)<0)||(t.allSeriesCollapsed=!1)}e.yaxis[s].min!==void 0&&(u=typeof e.yaxis[s].min==`function`?e.yaxis[s].min(u):e.yaxis[s].min),e.yaxis[s].max!==void 0&&(d=typeof e.yaxis[s].max==`function`?e.yaxis[s].max(d):e.yaxis[s].max),t.barGroups=t.barGroups.filter((e,t,n)=>n.indexOf(e)===t);let g=e.yaxis[s];o&&g.alignZero===!0&&!g.logarithmic&&g.min===void 0&&g.max===void 0&&t.ignoreYAxisIndexes.indexOf(s)<0&&_.isNumber(u)&&_.isNumber(d)?a.push({ai:s,minY:u,maxY:d}):(this.setYScaleForIndex(s,u,d),n.forEach(e=>{r[e]=t.yAxisScale[s].niceMin,i[e]=t.yAxisScale[s].niceMax}))}else this.setYScaleForIndex(s,0,-Number.MAX_VALUE)}),a.length>=2){a.forEach(e=>{this.setYScaleForIndex(e.ai,e.minY,e.maxY),n[e.ai].forEach(n=>{r[n]=t.yAxisScale[e.ai].niceMin,i[n]=t.yAxisScale[e.ai].niceMax})});let e=0;a.forEach(n=>{let r=t.yAxisScale[n.ai],i=r.niceMax-r.niceMin;if(i>0){let t=-r.niceMin/i;t>e&&(e=t)}}),e>1&&(e=1),e<0&&(e=0);let o=e=>{if(e<=0)return 1;let t=10**Math.floor(Math.log10(e)),n=e/t,r;return r=n<=1.000000001?1:n<=2.000000001?2:n<=2.500000001?2.5:n<=5.000000001?5:10,r*t};a.forEach(a=>{let s=t.yAxisScale[a.ai];if(!s.result||s.result.length<2)return;let c=s.niceMax-s.niceMin;if(c<=0)return;let u=-s.niceMin/c;if(Math.abs(u-e)<=1e-9)return;let d=u<e&&e<.999999999,f=!d&&u>e&&e>1e-9;if(!d&&!f)return;let p=d?-e*s.niceMax/(1-e):s.niceMin,m=f?-s.niceMin*(1-e)/e:s.niceMax,h=m-p;if(h<=0)return;let g=Math.max(s.result.length,5),v=o(h/Math.max(g-1,1));if(v<=0)return;let y,b;if(d){y=Math.floor(p/v+1e-9)*v;let t=e>1e-9?y*(e-1)/e:s.niceMax,n=Math.max(t,s.niceMax);b=Math.ceil(n/v-1e-9)*v}else{b=Math.ceil(m/v-1e-9)*v;let t=e<.999999999?-e*b/(1-e):s.niceMin,n=Math.min(t,s.niceMin);y=Math.floor(n/v+1e-9)*v}s.result=[];for(let e=y;e<=b+v*1e-9;e=_.preciseAddition(e,v))s.result.push(_.stripNumber(e,7));s.niceMin=y,s.niceMax=b,n[a.ai].forEach(e=>{r[e]=s.niceMin,i[e]=s.niceMax})})}else if(a.length===1){let e=a[0];this.setYScaleForIndex(e.ai,e.minY,e.maxY),n[e.ai].forEach(n=>{r[n]=t.yAxisScale[e.ai].niceMin,i[n]=t.yAxisScale[e.ai].niceMax})}}}class Range{constructor(e){this.w=e,this.scales=new Scales(this.w)}init(){this.setYRange(),this.setXRange(),this.setZRange()}_xPixelTolerance(e){let t=this.w.layout.gridWidth;if(!t||!e||!e.length)return 0;let n=this.w.config.xaxis,r=typeof n.min==`number`?n.min:e[0],i=typeof n.max==`number`?n.max:e[e.length-1];return i>r?(i-r)/t:0}_autoScaleYEnabled(){var e;let t=this.w.config,n=(e=this.w.globals.brushSource)==null?void 0:e.w.config.chart.brush;return!!(t.chart.zoom.enabled&&t.chart.zoom.autoScaleYaxis||n!=null&&n.enabled&&n!=null&&n.autoScaleYaxis)}_autoScaleXBounds(e){let t=this.w.config.xaxis;if(!t.min&&!t.max)return null;let n=this._xPixelTolerance(this.w.seriesData.seriesX[e]);return{lo:t.min?t.min-n:-1/0,hi:t.max?t.max+n:1/0}}getMinYMaxY(e,t=Number.MAX_VALUE,n=-Number.MAX_VALUE,r=null){var i,a,o,s,c,u,d,f;let p=this.w.config,m=this.w.globals,h=-Number.MAX_VALUE,g=Number.MIN_VALUE;r===null&&(r=e+1);let v=this.w.seriesData.series,y=v,b=v;p.chart.type===`candlestick`?(y=this.w.candleData.seriesCandleL,b=this.w.candleData.seriesCandleH):p.chart.type===`boxPlot`?(y=this.w.candleData.seriesCandleO,b=this.w.candleData.seriesCandleC):p.chart.type===`violin`?(y=this.w.violinData.seriesViolinMin,b=this.w.violinData.seriesViolinMax):this.w.axisFlags.isRangeData&&(y=this.w.rangeData.seriesRangeStart,b=this.w.rangeData.seriesRangeEnd);let x=!1,S=!1;this.w.seriesData.seriesX.length>=r&&this._autoScaleYEnabled()&&!this._ignoreAutoScaleWindow&&(x=!0);for(let C=e;C<r;C++){m.dataPoints=Math.max(m.dataPoints,v[C].length);let e=p.series[C].type;this.w.labelData.categoryLabels.length&&(m.dataPoints=this.w.labelData.categoryLabels.filter(e=>e!==void 0).length),this.w.labelData.labels.length&&p.xaxis.type!==`datetime`&&this.w.seriesData.series.reduce((e,t)=>e+t.length,0)!==0&&(m.dataPoints=Math.max(m.dataPoints,this.w.labelData.labels.length));let r=0,w=v[C].length-1;if(x){let e=this.w.seriesData.seriesX[C],t=this._autoScaleXBounds(C);if(t&&p.xaxis.min)for(;r<w&&e[r]<t.lo;r++);if(t&&p.xaxis.max)for(;w>r&&e[w]>t.hi;w--);t&&e&&e.length&&(e[r]>=t.lo&&e[r]<=t.hi||(e[0]<t.lo&&e[e.length-1]>t.hi&&r>0?(w=r,r=w-1):(r=0,w=-1,S=!0)))}if(y===v&&b===v&&p.chart.type!==`boxPlot`&&e!==`candlestick`&&e!==`boxPlot`&&e!==`violin`&&e!==`rangeArea`&&e!==`rangeBar`&&!(this.w.seriesData.seriesGoals[C]&&this.w.seriesData.seriesGoals[C].length)){let a=v[C],o=Math.min(w,a.length-1),s=(i=this.w.seriesData._parsedExtrema)==null?void 0:i[C];if(s&&s.ref===a&&s.len===a.length&&r===0&&o===a.length-1)s.maxY>h&&(h=s.maxY),s.lowestY<t&&(t=s.lowestY),s.negMinY<0&&s.negMinY<g&&(g=s.negMinY),s.yDec>m.yValueDecimal&&(m.yValueDecimal=s.yDec),s.hasNulls&&(m.hasNullValues=!0);else{let e=m.yValueDecimal,n=!1;for(let i=r;i<=o;i++){let r=a[i];if(r!==null&&typeof r==`number`&&r===r&&r!==1/0&&r!==-1/0){if(r>h&&(h=r),r<t&&(t=r),g>r&&r<0&&(g=r),!Number.isInteger(r)){let t=r<0?-r:r;if(t>=1e-6&&t<1e21){let t=``+r,n=t.indexOf(`.`),i=n===-1?0:t.length-n-1;i>e&&(e=i)}else{let t=_.noExponents(r);_.isFloat(t)&&(e=Math.max(e,t.toString().split(`.`)[1].length))}}}else n=!0}m.yValueDecimal=e,n&&(m.hasNullValues=!0)}n=h,(e===`bar`||e===`column`)&&(g<0&&h<0&&(h=0,n=Math.max(n,0)),g===Number.MIN_VALUE&&(g=0,t=Math.min(t,0)));continue}for(let i=r;i<=w&&i<this.w.seriesData.series[C].length;i++){let r=v[C][i];if(r!==null&&_.isNumber(r)){switch(((a=b[C])==null?void 0:a[i])!==void 0&&(h=Math.max(h,b[C][i]),t=Math.min(t,b[C][i])),((o=y[C])==null?void 0:o[i])!==void 0&&(t=Math.min(t,y[C][i]),n=Math.max(n,y[C][i])),e){case`candlestick`:this.w.candleData.seriesCandleC[C][i]!==void 0&&(h=Math.max(h,this.w.candleData.seriesCandleH[C][i]),t=Math.min(t,this.w.candleData.seriesCandleL[C][i]));break;case`boxPlot`:this.w.candleData.seriesCandleC[C][i]!==void 0&&(h=Math.max(h,this.w.candleData.seriesCandleC[C][i]),t=Math.min(t,this.w.candleData.seriesCandleO[C][i]));break;case`violin`:((s=this.w.violinData.seriesViolinMax[C])==null?void 0:s[i])!==void 0&&(h=Math.max(h,this.w.violinData.seriesViolinMax[C][i]),t=Math.min(t,this.w.violinData.seriesViolinMin[C][i]));break}if(e&&e!==`candlestick`&&e!==`boxPlot`&&e!==`violin`&&e!==`rangeArea`&&e!==`rangeBar`&&(h=Math.max(h,this.w.seriesData.series[C][i]),t=Math.min(t,this.w.seriesData.series[C][i])),this.w.seriesData.seriesGoals[C]&&this.w.seriesData.seriesGoals[C][i]&&Array.isArray(this.w.seriesData.seriesGoals[C][i])&&this.w.seriesData.seriesGoals[C][i].forEach(e=>{h=Math.max(h,e.value),t=Math.min(t,e.value)}),this.w.config.chart.type===`boxPlot`||e===`boxPlot`){let e=(u=(c=this.w.candleData.seriesBoxPoints)==null?void 0:c[C])==null?void 0:u[i];if(e)for(let n=0;n<e.length;n++){let r=e[n];typeof r==`number`&&(h=Math.max(h,r),t=Math.min(t,r))}}n=h,r=_.noExponents(r),_.isFloat(r)&&(m.yValueDecimal=Math.max(m.yValueDecimal,r.toString().split(`.`)[1].length)),g>((d=y[C])==null?void 0:d[i])&&((f=y[C])==null?void 0:f[i])<0&&(g=y[C][i])}else m.hasNullValues=!0}(e===`bar`||e===`column`)&&(g<0&&h<0&&(h=0,n=Math.max(n,0)),g===Number.MIN_VALUE&&(g=0,t=Math.min(t,0)))}if(p.chart.type===`rangeBar`&&this.w.rangeData.seriesRangeStart.length&&m.isBarHorizontal&&(g=t),p.chart.type===`bar`&&(g<0&&h<0&&(h=0),g===Number.MIN_VALUE&&(g=0)),S&&h===-Number.MAX_VALUE){this._ignoreAutoScaleWindow=!0;try{return this.getMinYMaxY(e,Number.MAX_VALUE,-Number.MAX_VALUE,r)}finally{this._ignoreAutoScaleWindow=!1}}return{minY:g,maxY:h,lowestY:t,highestY:n}}setYRange(){let e=this.w.globals,t=this.w.config;e.maxY=-Number.MAX_VALUE,e.minY=Number.MIN_VALUE;let n=Number.MAX_VALUE,r;if(e.isMultipleYAxis){n=Number.MAX_VALUE;for(let t=0;t<this.w.seriesData.series.length;t++)r=this.getMinYMaxY(t),e.minYArr[t]=r.lowestY,e.maxYArr[t]=r.highestY,n=Math.min(n,r.lowestY)}return r=this.getMinYMaxY(0,n,void 0,this.w.seriesData.series.length),t.chart.type===`bar`?(e.minY=r.minY,e.maxY=r.maxY):(e.minY=r.lowestY,e.maxY=r.highestY),n=r.lowestY,t.chart.stacked&&this._setStackedMinMax(),t.chart.type===`line`||t.chart.type===`area`||t.chart.type===`scatter`||t.chart.type===`candlestick`||t.chart.type===`boxPlot`||t.chart.type===`violin`||t.chart.type===`rangeBar`&&!e.isBarHorizontal?e.minY===Number.MIN_VALUE&&n!==-Number.MAX_VALUE&&n!==e.maxY&&(e.minY=n):e.minY=e.minY===Number.MIN_VALUE?r.minY:Math.min(r.minY,e.minY),t.yaxis.forEach((t,n)=>{t.max!==void 0&&(typeof t.max==`number`?e.maxYArr[n]=t.max:typeof t.max==`function`&&(e.maxYArr[n]=t.max(e.isMultipleYAxis?e.maxYArr[n]:e.maxY)),e.maxY=e.maxYArr[n]),t.min!==void 0&&(typeof t.min==`number`?e.minYArr[n]=t.min:typeof t.min==`function`&&(e.minYArr[n]=t.min(e.isMultipleYAxis?e.minYArr[n]===Number.MIN_VALUE?0:e.minYArr[n]:e.minY)),e.minY=e.minYArr[n])}),e.isBarHorizontal&&[`min`,`max`].forEach(n=>{t.xaxis[n]!==void 0&&typeof t.xaxis[n]==`number`&&(n===`min`?e.minY=t.xaxis[n]:e.maxY=t.xaxis[n])}),e.isMultipleYAxis?(this.scales.scaleMultipleYAxes(),e.minY=n):(this.scales.setYScaleForIndex(0,e.minY,e.maxY),e.minY=e.yAxisScale[0].niceMin,e.maxY=e.yAxisScale[0].niceMax,e.minYArr[0]=e.minY,e.maxYArr[0]=e.maxY),e.barGroups=[],e.lineGroups=[],e.areaGroups=[],t.series.forEach(n=>{let r=n;switch(r.type||t.chart.type){case`bar`:case`column`:e.barGroups.push(r.group);break;case`line`:e.lineGroups.push(r.group);break;case`area`:e.areaGroups.push(r.group);break}}),e.barGroups=e.barGroups.filter((e,t,n)=>n.indexOf(e)===t),e.lineGroups=e.lineGroups.filter((e,t,n)=>n.indexOf(e)===t),e.areaGroups=e.areaGroups.filter((e,t,n)=>n.indexOf(e)===t),{minY:e.minY,maxY:e.maxY,minYArr:e.minYArr,maxYArr:e.maxYArr,yAxisScale:e.yAxisScale}}setXRange(){let e=this.w.globals,t=this.w.config,n=t.xaxis.type===`numeric`||t.xaxis.type===`datetime`||t.xaxis.type===`category`&&!this.w.axisFlags.noLabelsProvided||this.w.axisFlags.noLabelsProvided||this.w.axisFlags.isXNumeric,r=()=>{var t;let n=e.minX,r=e.maxX;for(let e=0;e<this.w.seriesData.series.length;e++){let i=this.w.labelData.labels[e];if(!i)continue;let a=(t=this.w.seriesData._parsedExtrema)==null?void 0:t[e];if(a&&a.xNumeric&&a.xref===i&&a.len===i.length){a.maxX>r&&(r=a.maxX),a.minX<n&&(n=a.minX);continue}for(let e=0;e<i.length;e++){let t=i[e];t!==null&&typeof t==`number`&&t===t&&(t>r&&(r=t),t<n&&(n=t))}}e.maxX=r,e.initialMaxX=r,e.minX=n,e.initialMinX=n};if(this.w.axisFlags.isXNumeric&&r(),this.w.axisFlags.noLabelsProvided&&t.xaxis.categories.length===0&&(e.maxX=this.w.labelData.labels[this.w.labelData.labels.length-1],e.initialMaxX=this.w.labelData.labels[this.w.labelData.labels.length-1],e.minX=1,e.initialMinX=1),this.w.axisFlags.isXNumeric||this.w.axisFlags.noLabelsProvided||this.w.axisFlags.dataFormatXNumeric){let r=10;if(t.xaxis.tickAmount===void 0)r=Math.round(e.svgWidth/150),t.xaxis.type===`numeric`&&e.dataPoints<30&&(r=e.dataPoints-1),r>e.dataPoints&&e.dataPoints!==0&&(r=e.dataPoints-1);else if(t.xaxis.tickAmount===`dataPoints`){if(this.w.seriesData.series.length>1&&(r=this.w.seriesData.series[e.maxValsInArrayIndex].length-1),this.w.axisFlags.isXNumeric){let t=Math.round(e.maxX-e.minX);t<30&&(r=t)}}else r=t.xaxis.tickAmount;if(e.xTickAmount=r,t.xaxis.max!==void 0&&typeof t.xaxis.max==`number`&&(e.maxX=t.xaxis.max),t.xaxis.min!==void 0&&typeof t.xaxis.min==`number`&&(e.minX=t.xaxis.min),t.xaxis.range!==void 0&&(e.minX=e.maxX-t.xaxis.range),e.minX!==Number.MAX_VALUE&&e.maxX!==-Number.MAX_VALUE)if(t.xaxis.convertedCatToNumeric&&!this.w.axisFlags.dataFormatXNumeric){let t=[];for(let n=e.minX-1;n<e.maxX;n++)t.push(n+1);e.xAxisScale={result:t,niceMin:t[0],niceMax:t[t.length-1]}}else e.xAxisScale=this.scales.setXScale(e.minX,e.maxX);else e.xAxisScale=this.scales.linearScale(0,r,r,0,t.xaxis.stepSize),this.w.axisFlags.noLabelsProvided&&this.w.labelData.labels.length>0&&(e.xAxisScale=this.scales.linearScale(1,this.w.labelData.labels.length,r-1,0,t.xaxis.stepSize),this.w.seriesData.seriesX=this.w.labelData.labels.slice());n&&(this.w.labelData.labels=e.xAxisScale.result.slice())}return e.isBarHorizontal&&this.w.labelData.labels.length&&(e.xTickAmount=this.w.labelData.labels.length),this._handleSingleDataPoint(),this._getMinXDiff(),{minX:e.minX,maxX:e.maxX}}setZRange(){var e;let t=this.w.globals;if(!this.w.axisFlags.isDataXYZ)return;for(let e=0;e<this.w.seriesData.series.length;e++)if(this.w.seriesData.seriesZ[e]!==void 0)for(let n=0;n<this.w.seriesData.seriesZ[e].length;n++)this.w.seriesData.seriesZ[e][n]!==null&&_.isNumber(this.w.seriesData.seriesZ[e][n])&&(t.maxZ=Math.max(t.maxZ,this.w.seriesData.seriesZ[e][n]),t.minZ=Math.min(t.minZ,this.w.seriesData.seriesZ[e][n]));let n=((e=this.w.config.plotOptions)==null?void 0:e.bubble)||{};_.isNumber(n.minZ)&&n.minZ<t.minZ&&(t.minZ=n.minZ),_.isNumber(n.maxZ)&&n.maxZ>t.maxZ&&(t.maxZ=n.maxZ)}_handleSingleDataPoint(){let e=this.w.globals,t=this.w.config;if(e.minX===e.maxX){let n=new DateTime(this.w);if(t.xaxis.type===`datetime`){let r=n.getDate(e.minX);t.xaxis.labels.datetimeUTC?r.setUTCDate(r.getUTCDate()-2):r.setDate(r.getDate()-2),e.minX=new Date(r).getTime();let i=n.getDate(e.maxX);t.xaxis.labels.datetimeUTC?i.setUTCDate(i.getUTCDate()+2):i.setDate(i.getDate()+2),e.maxX=new Date(i).getTime()}else (t.xaxis.type===`numeric`||t.xaxis.type===`category`&&!this.w.axisFlags.noLabelsProvided)&&(e.minX-=2,e.initialMinX=e.minX,e.maxX+=2,e.initialMaxX=e.maxX)}}_getMinXDiff(){let e=this.w.globals;this.w.axisFlags.isXNumeric&&this.w.seriesData.seriesX.forEach((t,n)=>{var r;if(t.length){t.length===1&&t.push(this.w.seriesData.seriesX[e.maxValsInArrayIndex][this.w.seriesData.seriesX[e.maxValsInArrayIndex].length-1]);let i=(r=this.w.seriesData._parsedExtrema)==null?void 0:r[n];if(i&&i.xNumeric&&i.xSorted&&i.xref===t&&i.len===t.length){i.minXDiff<e.minXDiff&&(e.minXDiff=i.minXDiff),(e.dataPoints===1||e.minXDiff===Number.MAX_VALUE)&&(e.minXDiff=.5);return}let a=!0,o=e.minXDiff;for(let e=1;e<t.length;e++){let n=t[e]-t[e-1];if(n>0)n<o&&(o=n);else if(n<0){a=!1;break}}if(a){e.minXDiff=o,(e.dataPoints===1||e.minXDiff===Number.MAX_VALUE)&&(e.minXDiff=.5);return}let s=t.slice();s.sort((e,t)=>e-t),s.forEach((t,n)=>{if(n>0){let r=t-s[n-1];r>0&&(e.minXDiff=Math.min(r,e.minXDiff))}}),(e.dataPoints===1||e.minXDiff===Number.MAX_VALUE)&&(e.minXDiff=.5)}})}_setStackedMinMax(){let e=this.w.globals,t=this._autoScaleYEnabled();if(!this.w.seriesData.series.length)return;let n=this.w.labelData.seriesGroups;n.length||(n=[this.w.seriesData.seriesNames.map(e=>e)]);let r={},i={};n.forEach(n=>{r[n]=[],i[n]=[],this.w.config.series.map((e,t)=>n.indexOf(this.w.seriesData.seriesNames[t])>-1?t:null).filter(e=>e!==null).forEach(a=>{var o,s,c,u;let d=t?this._autoScaleXBounds(a):null,f=this.w.seriesData.seriesX[a],p=!!(d&&f&&f.length);for(let t=0;t<this.w.seriesData.series[e.maxValsInArrayIndex].length;t++)p&&(f[t]<d.lo||f[t]>d.hi)||(r[n][t]===void 0&&(r[n][t]=0,i[n][t]=0),(this.w.config.chart.stacked&&!e.comboCharts||this.w.config.chart.stacked&&e.comboCharts&&(!this.w.config.chart.stackOnlyBar||((s=(o=this.w.config.series)==null?void 0:o[a])==null?void 0:s.type)===`bar`||((u=(c=this.w.config.series)==null?void 0:c[a])==null?void 0:u.type)===`column`))&&this.w.seriesData.series[a][t]!==null&&_.isNumber(this.w.seriesData.series[a][t])&&(this.w.seriesData.series[a][t]>0?r[n][t]+=parseFloat(String(this.w.seriesData.series[a][t]))+1e-4:i[n][t]+=parseFloat(String(this.w.seriesData.series[a][t]))))})}),Object.entries(r).forEach(([t])=>{r[t].forEach((n,a)=>{e.maxY=Math.max(e.maxY,r[t][a]),e.minY=Math.min(e.minY,i[t][a])})})}}function Me(){return{palette1:[`#008FFB`,`#00A86F`,`#CA8501`,`#FF4560`,`#846DD5`],palette2:[`#6978CB`,`#039DE2`,`#49A84D`,`#B39105`,`#D68000`],palette3:[`#209FCC`,`#648291`,`#D4526E`,`#0FA783`,`#A19285`],palette4:[`#2FA59D`,`#73A20B`,`#099DE1`,`#FD5D5D`,`#648291`],palette5:[`#2B908F`,`#F56566`,`#2EAB16`,`#FA4443`,`#1EA2BD`],palette6:[`#449DD1`,`#F86624`,`#EA3A4A`,`#9C63D1`,`#899E2A`],palette7:[`#DF475B`,`#1B998B`,`#7E75B7`,`#F46036`,`#B1911B`],palette8:[`#9C63D1`,`#F86624`,`#B38F04`,`#EA3A4A`,`#2FA2B3`],palette9:[`#98776F`,`#A19285`,`#A8705E`,`#BA6560`,`#A0927F`],palette10:[`#C91EFF`,`#A94BFD`,`#6C6AFE`,`#2983FF`,`#009ED8`],cvdDeuteranopia:[`#0072B2`,`#E69F00`,`#56B4E9`,`#009E73`,`#F0E442`,`#D55E00`,`#CC79A7`],cvdProtanopia:[`#0077BB`,`#EE7733`,`#009988`,`#EE3377`,`#BBBBBB`,`#33BBEE`,`#CC3311`],cvdTritanopia:[`#CC3311`,`#009988`,`#EE7733`,`#0077BB`,`#EE3377`,`#BBBBBB`,`#33BBEE`],highContrast:[`#005A9C`,`#C00000`,`#007A33`,`#6C3483`,`#7B3F00`,`#0097A7`,`#4A235A`]}}class YAxis{constructor(e,{theme:t=null,timeScale:n=null}={},r){this.w=e,this.elgrid=r,this.xaxisFontSize=e.config.xaxis.labels.style.fontSize,this.axisFontFamily=e.config.xaxis.labels.style.fontFamily,this.xaxisForeColors=e.config.xaxis.labels.style.colors,this.isCategoryBarHorizontal=e.config.chart.type===`bar`&&e.config.plotOptions.bar.horizontal,this.xAxisoffX=e.config.xaxis.position===`bottom`?e.layout.gridHeight:0,this.drawnLabels=[],this.axesUtils=new AxesUtils(e,{theme:t,timeScale:n})}drawYaxis(e){let t=this.w,n=new Graphics(this.w),r=t.config.yaxis[e].labels.style,{fontSize:i,fontFamily:a,fontWeight:o}=r,s=n.group({class:`apexcharts-yaxis`,rel:e,transform:`translate(${t.globals.translateYAxisX[e]}, 0)`});if(this.axesUtils.isYAxisHidden(e))return s;let c=n.group({class:`apexcharts-yaxis-texts-g`});s.add(c);let u=t.globals.yAxisScale[e].result.length-1,d=t.layout.gridHeight/u,f=t.formatters.yLabelFormatters[e],p=this.axesUtils.checkForReversedLabels(e,t.globals.yAxisScale[e].result.slice()),m=1;if(t.config.chart.type===`heatmap`&&!t.config.yaxis[e].labels.formatter){let e=parseInt(i,10)||11,n=Math.max(1,Math.floor(t.layout.gridHeight/(e*1.4))),r=u+1;r>n&&(m=Math.ceil(r/n))}if(t.config.yaxis[e].labels.show){let s=t.layout.translateY+t.config.yaxis[e].labels.offsetY;t.globals.isBarHorizontal?s=0:t.config.chart.type===`heatmap`&&(s-=d/2),s+=parseInt(i,10)/3;let h=null;for(let g=u;g>=0;g--){let u=m>1&&g%m!==0?``:f(p[g],g,t),_=t.config.yaxis[e].labels.padding;t.config.yaxis[e].opposite&&t.config.yaxis.length!==0&&(_*=-1);let v=this.getTextAnchor(t.config.yaxis[e].labels.align,t.config.yaxis[e].opposite),y=this.axesUtils.getYAxisForeColor(r.colors,e),b=Array.isArray(y)?y[g]:y,x=Array.from(t.dom.baseEl.querySelectorAll(`.apexcharts-yaxis[rel='${e}'] .apexcharts-yaxis-label tspan`)).map(e=>e.textContent),S=n.drawText({x:_,y:s,text:x.includes(u)&&!t.config.yaxis[e].labels.showDuplicates?``:u,textAnchor:v,fontSize:i,fontFamily:a,fontWeight:o,maxWidth:t.config.yaxis[e].labels.maxWidth,foreColor:b,isPlainText:!1,cssClass:`apexcharts-yaxis-label ${r.cssClass}`});c.add(S),this.addTooltip(S,u),h===null&&(h=S),t.config.yaxis[e].labels.rotate!==0&&this.rotateLabel(n,S,h,t.config.yaxis[e].labels.rotate),s+=d}}return this.addYAxisTitle(n,s,e),this.addAxisBorder(n,s,e,u,d),s}getTextAnchor(e,t){return e===`left`?`start`:e===`center`?`middle`:e===`right`?`end`:t?`start`:`end`}addTooltip(e,t){let n=BrowserAPIs.createElementNS(P,`title`);n.textContent=Array.isArray(t)?t.join(` `):t,e.node.appendChild(n)}rotateLabel(e,t,n,r){let i=e.rotateAroundCenter(n.node),a=e.rotateAroundCenter(t.node);t.node.setAttribute(`transform`,`rotate(${r} ${i.x} ${a.y})`)}addYAxisTitle(e,t,n){let r=this.w;if(r.config.yaxis[n].title.text!==void 0){let i=e.group({class:`apexcharts-yaxis-title`}),a=r.config.yaxis[n].opposite?r.globals.translateYAxisX[n]:0,o=e.drawText({x:a,y:r.layout.gridHeight/2+r.layout.translateY+r.config.yaxis[n].title.offsetY,text:r.config.yaxis[n].title.text,textAnchor:`end`,foreColor:r.config.yaxis[n].title.style.color,fontSize:r.config.yaxis[n].title.style.fontSize,fontWeight:r.config.yaxis[n].title.style.fontWeight,fontFamily:r.config.yaxis[n].title.style.fontFamily,cssClass:`apexcharts-yaxis-title-text ${r.config.yaxis[n].title.style.cssClass}`});i.add(o),t.add(i)}}addAxisBorder(e,t,n,r,i){let a=this.w,o=a.config.yaxis[n].axisBorder,s=31+o.offsetX;if(a.config.yaxis[n].opposite&&(s=-31-o.offsetX),o.show){let n=e.drawLine(s,a.layout.translateY+o.offsetY-2,s,a.layout.gridHeight+a.layout.translateY+o.offsetY+2,o.color,0,o.width);t.add(n)}a.config.yaxis[n].axisTicks.show&&this.axesUtils.drawYAxisTicks(s,r,o,a.config.yaxis[n].axisTicks,n,i,t)}drawYaxisInversed(e){let t=this.w,n=new Graphics(this.w),r=n.group({class:`apexcharts-xaxis apexcharts-yaxis-inversed`}),i=n.group({class:`apexcharts-xaxis-texts-g`,transform:`translate(${t.layout.translateXAxisX}, ${t.layout.translateXAxisY})`});r.add(i);let a=t.globals.yAxisScale[e].result.length-1,o=t.layout.gridWidth/a+.1,s=o+t.config.xaxis.labels.offsetX,c=t.formatters.xLabelFormatter,u=this.axesUtils.checkForReversedLabels(e,t.globals.yAxisScale[e].result.slice()),d=t.labelData.timescaleLabels;if(d.length>0&&(this.xaxisLabels=d.slice(),u=d.slice(),a=u.length),t.config.xaxis.labels.show)for(let r=d.length?0:a;d.length?r<d.length:r>=0;d.length?r++:r--){let a=c==null?void 0:c(u[r],r,t),f=t.layout.gridWidth+t.globals.padHorizontal-(s-o+t.config.xaxis.labels.offsetX);if(d.length){let e=this.axesUtils.getLabel(u,d,f,r,this.drawnLabels,this.xaxisFontSize);f=e.x,a=e.text,this.drawnLabels.push(e.text),r===0&&t.globals.skipFirstTimelinelabel&&(a=``),r===u.length-1&&t.globals.skipLastTimelinelabel&&(a=``)}let p=n.drawText({x:f,y:this.xAxisoffX+t.config.xaxis.labels.offsetY+30-(t.config.xaxis.position===`top`?t.layout.xAxisHeight+t.config.xaxis.axisTicks.height-2:0),text:a,textAnchor:`middle`,foreColor:Array.isArray(this.xaxisForeColors)?this.xaxisForeColors[e]:this.xaxisForeColors,fontSize:this.xaxisFontSize,fontFamily:this.axisFontFamily,fontWeight:t.config.xaxis.labels.style.fontWeight,isPlainText:!1,cssClass:`apexcharts-xaxis-label ${t.config.xaxis.labels.style.cssClass}`});i.add(p),this.addTooltip(p,a),s+=o}return this.inversedYAxisTitleText(r),this.inversedYAxisBorder(r),r}inversedYAxisBorder(e){let t=this.w,n=new Graphics(this.w),r=t.config.xaxis.axisBorder;if(r.show){let i=0;t.config.chart.type===`bar`&&t.axisFlags.isXNumeric&&(i-=15);let a=n.drawLine(t.globals.padHorizontal+i+r.offsetX,this.xAxisoffX,t.layout.gridWidth,this.xAxisoffX,r.color,0,r.height);this.elgrid&&this.elgrid.elGridBorders&&t.config.grid.show?this.elgrid.elGridBorders.add(a):e.add(a)}}inversedYAxisTitleText(e){let t=this.w,n=new Graphics(this.w);if(t.config.xaxis.title.text!==void 0){let r=n.group({class:`apexcharts-xaxis-title apexcharts-yaxis-title-inversed`}),i=n.drawText({x:t.layout.gridWidth/2+t.config.xaxis.title.offsetX,y:this.xAxisoffX+parseFloat(this.xaxisFontSize)+parseFloat(t.config.xaxis.title.style.fontSize)+t.config.xaxis.title.offsetY+20,text:t.config.xaxis.title.text,textAnchor:`middle`,fontSize:t.config.xaxis.title.style.fontSize,fontFamily:t.config.xaxis.title.style.fontFamily,fontWeight:t.config.xaxis.title.style.fontWeight,foreColor:t.config.xaxis.title.style.color,cssClass:`apexcharts-xaxis-title-text ${t.config.xaxis.title.style.cssClass}`});r.add(i),e.add(r)}}yAxisTitleRotate(e,t){let n=this.w,r=new Graphics(this.w),i=n.dom.baseEl.querySelector(`.apexcharts-yaxis[rel='${e}'] .apexcharts-yaxis-texts-g`),a=i?i.getBoundingClientRect():{width:0,height:0},o=n.dom.baseEl.querySelector(`.apexcharts-yaxis[rel='${e}'] .apexcharts-yaxis-title text`),s=o?o.getBoundingClientRect():{width:0,height:0};if(o){let i=this.xPaddingForYAxisTitle(e,a,s,t);o.setAttribute(`x`,String(i.xPos-(t?10:0)));let c=r.rotateAroundCenter(o);o.setAttribute(`transform`,`rotate(${t?n.config.yaxis[e].title.rotate*-1:n.config.yaxis[e].title.rotate} ${c.x} ${c.y})`)}}xPaddingForYAxisTitle(e,t,n,r){let i=this.w,a=0,o=10;return i.config.yaxis[e].title.text===void 0||e<0?{xPos:a,padd:0}:(r?a=t.width+i.config.yaxis[e].title.offsetX+n.width/2+o/2:(a=t.width*-1+i.config.yaxis[e].title.offsetX+o/2+n.width/2,i.globals.isBarHorizontal&&(o=25,a=t.width*-1-i.config.yaxis[e].title.offsetX-o)),{xPos:a,padd:o})}setYAxisXPosition(e,t){let n=this.w,r=0,i=0,a=18,o=1;n.config.yaxis.length>1&&(this.multipleYs=!0),n.config.yaxis.forEach((s,c)=>{let u=n.globals.ignoreYAxisIndexes.includes(c)||!s.show||s.floating||e[c].width===0,d=e[c].width+t[c].width;s.opposite?n.globals.isBarHorizontal?(i=n.layout.gridWidth+n.layout.translateX-1,n.globals.translateYAxisX[c]=i-s.labels.offsetX):(i=n.layout.gridWidth+n.layout.translateX+o,u||(o+=d+20),n.globals.translateYAxisX[c]=i-s.labels.offsetX+20):(r=n.layout.translateX-a,u||(a+=d+20),n.globals.translateYAxisX[c]=r+s.labels.offsetX)})}setYAxisTextAlignments(){let e=this.w;Array.from(e.dom.baseEl.getElementsByClassName(`apexcharts-yaxis`)).forEach((t,n)=>{let r=e.config.yaxis[n];if(r&&!r.floating&&r.labels.align!==void 0){let t=e.dom.baseEl.querySelector(`.apexcharts-yaxis[rel='${n}'] .apexcharts-yaxis-texts-g`),i=Array.from(e.dom.baseEl.querySelectorAll(`.apexcharts-yaxis[rel='${n}'] .apexcharts-yaxis-label`)),a=t.getBoundingClientRect();i.forEach(e=>{e.setAttribute(`text-anchor`,r.labels.align)}),r.labels.align===`left`&&!r.opposite?t.setAttribute(`transform`,`translate(-${a.width}, 0)`):r.labels.align===`center`?t.setAttribute(`transform`,`translate(${a.width/2*(r.opposite?1:-1)}, 0)`):r.labels.align===`right`&&r.opposite&&t.setAttribute(`transform`,`translate(${a.width}, 0)`)}})}}class Events{constructor(e,t){this.w=e,this.ctx=t,this.documentEvent=this.documentEvent.bind(this)}addEventListener(e,t){let n=this.w;Object.prototype.hasOwnProperty.call(n.globals.events,e)?n.globals.events[e].push(t):n.globals.events[e]=[t]}removeEventListener(e,t){let n=this.w;if(!Object.prototype.hasOwnProperty.call(n.globals.events,e))return;let r=n.globals.events[e].indexOf(t);r!==-1&&n.globals.events[e].splice(r,1)}fireEvent(e,t){let n=this.w;if(!Object.prototype.hasOwnProperty.call(n.globals.events,e))return;(!t||!t.length)&&(t=[]);let r=n.globals.events[e],i=r.length;for(let e=0;e<i;e++)r[e].apply(null,t)}setupEventHandlers(){let e=this.w,t=this.ctx,n=e.dom.baseEl.querySelector(e.globals.chartClass);this.ctx.eventList.forEach(r=>{n==null||n.addEventListener(r,n=>{let r=n.target.getAttribute(`i`)===null&&e.interact.capturedSeriesIndex!==-1?e.interact.capturedSeriesIndex:n.target.getAttribute(`i`),i=n.target.getAttribute(`j`)===null&&e.interact.capturedDataPointIndex!==-1?e.interact.capturedDataPointIndex:n.target.getAttribute(`j`),a=Object.assign({},e,{seriesIndex:e.globals.axisCharts?r:0,dataPointIndex:i});n.type===`keydown`?e.config.chart.accessibility.enabled&&e.config.chart.accessibility.keyboard.enabled&&(t.ctx.keyboardNavigation&&t.ctx.keyboardNavigation.handleKey(n),typeof e.config.chart.events.keyDown==`function`&&e.config.chart.events.keyDown(n,t,a),t.ctx.events.fireEvent(`keydown`,[n,t,a])):n.type===`keyup`?e.config.chart.accessibility.enabled&&e.config.chart.accessibility.keyboard.enabled&&(typeof e.config.chart.events.keyUp==`function`&&e.config.chart.events.keyUp(n,t,a),t.ctx.events.fireEvent(`keyup`,[n,t,a])):n.type===`mousemove`||n.type===`touchmove`?typeof e.config.chart.events.mouseMove==`function`&&e.config.chart.events.mouseMove(n,t,a):n.type===`mouseleave`||n.type===`touchleave`?typeof e.config.chart.events.mouseLeave==`function`&&e.config.chart.events.mouseLeave(n,t,a):(n.type===`mouseup`&&n.which===1||n.type===`touchend`)&&(typeof e.config.chart.events.click==`function`&&e.config.chart.events.click(n,t,a),t.ctx.events.fireEvent(`click`,[n,t,a]))},{capture:!1,passive:!0})}),this.ctx.eventList.forEach(t=>{e.dom.baseEl.addEventListener(t,this.documentEvent,{passive:!0})}),this.ctx.core.setupBrushHandler()}documentEvent(e){let t=this.w,n=e.target.className;if(e.type===`click`){let e=t.dom.baseEl.querySelector(`.apexcharts-menu`);e&&e.classList.contains(`apexcharts-menu-open`)&&n!==`apexcharts-menu-icon`&&e.classList.remove(`apexcharts-menu-open`)}t.interact.clientX=e.type===`touchmove`?e.touches[0].clientX:e.clientX,t.interact.clientY=e.type===`touchmove`?e.touches[0].clientY:e.clientY}}class Localization{constructor(e){this.w=e}setCurrentLocaleValues(e){let t=this.w.config.chart.locales,n=Environment.getApex();n.chart&&n.chart.locales&&n.chart.locales.length>0&&(t=this.w.config.chart.locales.concat(n.chart.locales));let r=t.filter(t=>t.name===e)[0];if(r){let e=_.extend(y,r);this.w.globals.locale=e.options}else throw Error(`Wrong locale name provided. Please make sure you set the correct locale name in options`)}}class Axes{constructor(e,t){this.w=e,this.ctx=t}drawAxis(e,t){let n=this.w.globals,r=this.w.config,i=new XAxis(this.w,this.ctx,t),a=new YAxis(this.w,{theme:this.ctx.theme,timeScale:this.ctx.timeScale},t);if(n.axisCharts&&e!==`radar`){let e,t;n.isBarHorizontal?(t=a.drawYaxisInversed(0),e=i.drawXaxisInversed(0),this.w.dom.elGraphical.add(e),this.w.dom.elGraphical.add(t)):(e=i.drawXaxis(),this.w.dom.elGraphical.add(e),r.yaxis.map((e,r)=>{if(n.ignoreYAxisIndexes.indexOf(r)===-1&&(t=a.drawYaxis(r),this.w.dom.Paper.add(t),this.w.config.grid.position===`back`)){let e=this.w.dom.Paper.children()[1];e&&(e.remove(),this.w.dom.Paper.add(e))}}))}}}class Crosshairs{constructor(e){this.w=e}drawXCrosshairs(){let e=this.w;e.dom.elGraphical.node.querySelectorAll(`:scope > .apexcharts-xcrosshairs`).forEach(e=>e.remove());let t=new Graphics(this.w),n=new Filters(this.w),r=e.config.xaxis.crosshairs.fill.gradient,i=e.config.xaxis.crosshairs.dropShadow,a=e.config.xaxis.crosshairs.fill.type,o=r.colorFrom,s=r.colorTo,c=r.opacityFrom,u=r.opacityTo,d=r.stops,f=`none`,p=i.enabled,m=i.left,h=i.top,g=i.blur,v=i.color,y=i.opacity,b=e.config.xaxis.crosshairs.fill.color;if(e.config.xaxis.crosshairs.show){a===`gradient`&&(b=t.drawGradient(`vertical`,o,s,c,u,null,d,[]));let r=e.config.xaxis.crosshairs.width===1?t.drawLine(0,0,0,0):t.drawRect(),i=e.layout.gridHeight;(!_.isNumber(i)||i<0)&&(i=0);let f=e.config.xaxis.crosshairs.width;(!_.isNumber(f)||Number(f)<0)&&(f=0),r.attr({class:`apexcharts-xcrosshairs`,x:0,y:0,y2:i,width:f,height:i,fill:b,filter:`none`,"fill-opacity":e.config.xaxis.crosshairs.opacity,stroke:e.config.xaxis.crosshairs.stroke.color,"stroke-width":e.config.xaxis.crosshairs.stroke.width,"stroke-dasharray":e.config.xaxis.crosshairs.stroke.dashArray}),p&&(r=n.dropShadow(r,{left:m,top:h,blur:g,color:v,opacity:y})),e.dom.elGraphical.add(r)}}drawYCrosshairs(){let e=this.w;e.dom.elGraphical.node.querySelectorAll(`:scope > .apexcharts-ycrosshairs, :scope > .apexcharts-ycrosshairs-hidden`).forEach(e=>e.remove());let t=new Graphics(this.w),n=e.config.yaxis[0].crosshairs,r=e.globals.barPadForNumericAxis;if(e.config.yaxis[0].crosshairs.show){let i=t.drawLine(-r,0,e.layout.gridWidth+r,0,n.stroke.color,n.stroke.dashArray,n.stroke.width);i.attr({class:`apexcharts-ycrosshairs`}),e.dom.elGraphical.add(i)}let i=t.drawLine(-r,0,e.layout.gridWidth+r,0,n.stroke.color,0,0);i.attr({class:`apexcharts-ycrosshairs-hidden`}),e.dom.elGraphical.add(i)}}function Ne(e,t){if(!_.isObject(e)||!_.isObject(t))return t===void 0?e:t;let n=s({},e);for(let r of Object.keys(t)){let i=t[r];i!==void 0&&(_.isObject(i)&&_.isObject(e[r])?n[r]=Ne(e[r],i):n[r]=i)}return n}class Responsive{constructor(e){this.w=e,this._activeBreakpoint=null}checkResponsiveConfig(e){let t=this.w,n=t.config;if(n.responsive.length===0)return;let r=n.responsive.slice();r.sort((e,t)=>e.breakpoint>t.breakpoint?1:t.breakpoint>e.breakpoint?-1:0).reverse();let i=new Config({}),a=(e={})=>{var n;let a=r[0].breakpoint,o=Environment.isBrowser()?window.innerWidth>0?window.innerWidth:screen.width:0;if(o>a){if(this._activeBreakpoint!==null){if(!t.globals.initialConfig)return;let n=_.clone(t.globals.initialConfig);n.series=_.clone(t.config.series);let r=CoreUtils.extendArrayProps(i,n,t);e=_.extend(r,e),this.overrideResponsiveOptions(e),this._activeBreakpoint=null}}else for(let a=0;a<r.length;a++)if(o<r[a].breakpoint){let o=(n=r[a].options)!=null&&n.yaxis?_.clone(r[a].options.yaxis):null;if(e=CoreUtils.extendArrayProps(i,r[a].options,t),e=_.extend(t.config,e),Array.isArray(t.config.yaxis)&&o){let n=Array.isArray(o)?o:[o];e=c(s({},e),{yaxis:t.config.yaxis.map((e,t)=>Ne(e,n[t]))})}this.overrideResponsiveOptions(e),this._activeBreakpoint=r[a].breakpoint}};if(e){let n=CoreUtils.extendArrayProps(i,e,t);n=_.extend(t.config,n),n=_.extend(n,e),a(n)}else a({})}overrideResponsiveOptions(e){let t=new Config(e).init({responsiveOverride:!0});this.w.config=t}}function Pe(e){var t,n,r;let i=e.globals;if(i.streamScrolled=!1,!i.axisCharts||!e.seriesData||!Array.isArray(e.seriesData.series)||e.seriesData.series.length===0){i.prevStreamFrame=null;return}let a=[];(n=(t=e.dom)==null?void 0:t.baseEl)!=null&&n.querySelectorAll&&e.dom.baseEl.querySelectorAll(`.apexcharts-marker`).forEach(e=>{var t,n,r,i,o;let s=parseInt((t=e.getAttribute(`index`))==null?``:t,10),c=parseInt((r=(n=e.getAttribute(`j`))==null?e.getAttribute(`rel`):n)==null?``:r,10),u=parseFloat((o=(i=e.getAttribute(`r`))==null?e.getAttribute(`default-marker-size`):i)==null?``:o);isFinite(s)&&isFinite(c)&&isFinite(u)&&((a[s]=a[s]||[])[c]=u)}),i.prevStreamFrame={seriesX:(e.seriesData.seriesX||[]).slice(),seriesY:e.seriesData.series.slice(),xPixels:(i.seriesXvalues||[]).slice(),yPixels:(i.seriesYvalues||[]).slice(),rPixels:a,labels:(i.labels||[]).slice(),isXNumeric:!!((r=e.axisFlags)!=null&&r.isXNumeric)}}function Fe(e,t){let n=t.config.chart.streaming;if(!n||!n.enabled)return;let r=n.maxPoints,i=t.config.xaxis.range,a=e=>e==null?null:Array.isArray(e)?typeof e[0]==`number`?e[0]:null:typeof e==`object`&&typeof e.x==`number`?e.x:null;e.forEach(e=>{var t;let n=e==null?void 0:e.data;if(!Array.isArray(n)||n.length<2)return;if(typeof r==`number`&&r>0){n.length>r&&(e.data=n.slice(n.length-r));return}if(!i)return;let o=a(n[n.length-1]),s=a(n[0]);if(o==null||s==null||o<=s)return;let c=(o-s)/(n.length-1),u=o-i-2*c,d=0;for(;d<n.length&&((t=a(n[d]))==null?u:t)<u;)d++;d>0&&(e.data=n.slice(d))})}function Ie(e){var t;let n=e.config.chart.animations;if(!n||n.enabled===!1||!n.dynamicAnimation||n.dynamicAnimation.enabled===!1)return!1;let r=(t=n.largeDatasetThreshold)==null?0:t;return r>0&&e.globals.dataPoints>r?!1:!!(Environment.isBrowser()&&e.globals.dataChanged&&e.globals.shouldAnimate)}function Le(e,t,n){var r,i,a,o;if((r=e.axisFlags)!=null&&r.isXNumeric){let r=(a=(i=e.seriesData)==null?void 0:i.seriesX)==null?void 0:a[t];if(r&&r.length&&r[n]!=null)return`x:`+r[n]}let s=(o=e.globals.labels)==null?void 0:o[n];return s!=null&&String(s)!==``?`c:`+(Array.isArray(s)?s.join(` `):String(s)):`j:`+n}function Re(e,t,n){var r,i;if(e.isXNumeric){let i=(r=e.seriesX)==null?void 0:r[t];if(i&&i.length&&i[n]!=null)return`x:`+i[n]}let a=(i=e.labels)==null?void 0:i[n];return a!=null&&String(a)!==``?`c:`+(Array.isArray(a)?a.join(` `):String(a)):`j:`+n}function ze(e,t){let n=/* @__PURE__ */ new Map;e.forEach((e,t)=>{n.has(e)||n.set(e,t)});let r=Array(t.length),i=/* @__PURE__ */ new Set,a=-1,o=!0,s=e.length===t.length;t.forEach((e,t)=>{let c=n.has(e)&&!i.has(n.get(e))?n.get(e):-1;r[t]=c,c!==-1&&(i.add(c),c<a&&(o=!1),a=c),c!==t&&(s=!1)});let c=[];for(let t=0;t<e.length;t++)i.has(t)||c.push(t);return{toOld:r,exits:c,ordered:o,changed:!s}}function Be(e){let t=/* @__PURE__ */ new Map;return e.map(e=>{let n=t.get(e)||0;return t.set(e,n+1),n===0?e:`${e}#${n}`})}function Ve(e,t,n=!1,r=!1){var i,a;if(!Ie(e))return null;let o=e.globals.prevStreamFrame;if(!o)return null;let s=(i=o.seriesY)==null?void 0:i[t],c=(a=e.seriesData.series)==null?void 0:a[t];if(!Array.isArray(s)||!Array.isArray(c)||!s.length||!c.length)return null;let u=Be(s.map((e,n)=>Re(o,t,n))),d=Be(c.map((n,r)=>Le(e,t,r))),f=ze(u,d);return!f.ordered&&!r||!f.changed&&!n?null:{join:f,oldKeys:u,newKeys:d}}function He(e){var t,n;let r=e.config.chart.animations;return ge((n=(t=r.dynamicAnimation)==null?void 0:t.easing)==null?r.easing:n)}function K(e,t,n,r,i){let a=performance.now(),o=s=>{if(e.globals.isDestroyed)return;let c=Math.max(0,Math.min(1,(s-a)/t));r(n(c),c),c<1?BrowserAPIs.requestAnimationFrame(o):i&&i()};BrowserAPIs.requestAnimationFrame(o)}function Ue(e,t,n){return[...e.querySelectorAll(t)].map(e=>{var t,r,i;return{text:e.textContent||``,display:(i=(r=(t=e.querySelector(`tspan`))==null?void 0:t.textContent)==null?e.textContent:r)==null?``:i,pos:parseFloat(e.getAttribute(n)||``),transform:e.getAttribute(`transform`)}})}function We(e,t,n){return[...e.querySelectorAll(t)].map(e=>parseFloat(e.getAttribute(n)||``))}const Ge=`:not(.apexcharts-tick-ghost)`,Ke=`.apexcharts-xaxis-texts-g text:not(.apexcharts-xaxis-group-label)${Ge}`,qe=`.apexcharts-yaxis-texts-g text${Ge}`,Je=`.apexcharts-gridlines-vertical line${Ge}`,Ye=`.apexcharts-gridlines-horizontal line${Ge}`;function Xe(e){var t,n;let r=e.globals;if(!((t=e.axisFlags)!=null&&t.isXNumeric)||r.isBarHorizontal||(n=e.config.xaxis)!=null&&n.reversed)return null;let i=r.minX,a=r.maxX,o=e.layout.gridWidth;return!isFinite(i)||!isFinite(a)||!(a>i)||!(o>0)?null:{min:i,max:a,width:o}}function Ze(e,t){var n;let r=e.globals;if(r.isBarHorizontal||!Array.isArray(e.config.yaxis)||e.config.yaxis.length!==1||(n=e.config.yaxis[0])!=null&&n.logarithmic)return null;let i=r.minY,a=r.maxY;if(!isFinite(i)||!isFinite(a)||!(a>i))return null;let o=t.map(e=>e.pos).filter(e=>isFinite(e));return o.length<2?null:{min:i,max:a,pLo:Math.max(...o),pHi:Math.min(...o)}}function Qe(e,t){if(!e||!t)return null;let n=e.max-e.min,r=t.max-t.min;return!(n>0)||!(r>0)||!(e.width>0)||!(t.width>0)?null:{toNew:i=>(e.min+i/e.width*n-t.min)/r*t.width,toOld:i=>(t.min+i/t.width*r-e.min)/n*e.width}}function $e(e,t){if(!e||!t)return null;let n=e.pHi-e.pLo,r=t.pHi-t.pLo,i=e.max-e.min,a=t.max-t.min;if(!n||!r||!(i>0)||!(a>0))return null;let o=t=>e.min+(t-e.pLo)/n*i,s=e=>t.min+(e-t.pLo)/r*a;return{toNew:e=>t.pLo+(o(e)-t.min)/a*r,toOld:t=>e.pLo+(s(t)-e.min)/i*n}}function et(e){let t=e.globals;if(t.prevChromeFrame=null,!t.axisCharts||!Environment.isBrowser())return;let n=e.dom.baseEl;if(_.elementExists(n))try{let r=Ue(n,qe,`y`);t.prevChromeFrame={xLabels:Ue(n,Ke,`x`),yLabels:r,vGrid:We(n,Je,`x1`),hGrid:We(n,Ye,`y1`),xScale:Xe(e),yAnchors:Ze(e,r)}}catch(e){t.prevChromeFrame=null}}function tt(e,t,n,r){let i=t.style;i.opacity=`0`,K(e,n,r,e=>{i.opacity=String(e)},()=>{i.opacity=``})}function nt(e,t,n,r,i,a,o){n.forEach(e=>t.setAttribute(e,String(r))),K(e,a,o,e=>{let a=String(r+(i-r)*e);n.forEach(e=>t.setAttribute(e,a))},()=>{n.forEach(e=>t.setAttribute(e,String(i)))})}function rt(e,{template:t,display:n,attrs:r,from:i,to:a,duration:o,ease:s}){let c=t.parentNode;if(!c)return;let u=t.cloneNode(!0);if(u.classList.add(`apexcharts-tick-ghost`),u.setAttribute(`pointer-events`,`none`),u.removeAttribute(`id`),n!==void 0){let e=u.querySelector(`tspan`);e?e.textContent=n:u.textContent=n;let t=u.querySelector(`title`);t&&(t.textContent=n)}r.forEach(e=>u.setAttribute(e,String(i)));let d=u.style;d.opacity=`1`,c.appendChild(u),K(e,o,s,e=>{let t=String(i+(a-i)*e);r.forEach(e=>u.setAttribute(e,t)),d.opacity=String(1-e)},()=>{u.parentNode&&u.parentNode.removeChild(u)})}const it=20;function at(e,{newLabels:t,oldLabels:n,posAttr:r,newLines:i,oldLines:a,lineAttrs:o,duration:u,ease:d,project:f}){let p=/* @__PURE__ */ new Map;n.forEach((e,t)=>{p.has(e.text)||p.set(e.text,c(s({},e),{i:t}))});let m=/* @__PURE__ */ new Set,h=i.length===t.length,g=a.length===n.length,_=n.map(e=>e.pos).concat(t.map(e=>parseFloat(e.getAttribute(r)||``))).filter(e=>isFinite(e)),v=Math.min(..._),y=Math.max(..._),b=Math.max(40,(y-v)*.25),x=e=>Math.max(v-b,Math.min(y+b,e)),S=(t,n)=>{if(!t)return;let r=parseFloat(t.getAttribute(o[0])||``),i=a[n.i];isFinite(r)&&isFinite(i)&&nt(e,t,o,i,r,u,d)};if(t.forEach((t,n)=>{let a=parseFloat(t.getAttribute(r)||``),s=p.get(t.textContent||``),c=h?i[n]:null;s&&m.add(s.i);let g=t.getAttribute(`transform`);if(!s||!isFinite(s.pos)){if(!s){if(f&&isFinite(a)&&!g){let n=isFinite(f.toOld(a))?x(f.toOld(a)):NaN;isFinite(n)&&Math.abs(n-a)>.5&&(nt(e,t,[r],n,a,u,d),c&&nt(e,c,o,n,a,u,d))}tt(e,t,u,d),c&&tt(e,c,u,d)}return}if(!(!isFinite(a)||Math.abs(s.pos-a)<.5)){if(g||s.transform){let n=s.pos-a;if(isFinite(n)){let i=g||``;K(e,u,d,e=>{let a=n*(1-e),o=r===`x`?`translate(${a} 0)`:`translate(0 ${a})`;t.setAttribute(`transform`,`${o} ${i}`.trim())},()=>{i?t.setAttribute(`transform`,i):t.removeAttribute(`transform`)})}S(c,s);return}nt(e,t,[r],s.pos,a,u,d),S(c,s)}}),!f||!t.length)return;let C=0;n.forEach((n,s)=>{if(m.has(s)||!isFinite(n.pos)||n.transform||C>=20)return;let c=f.toNew(n.pos);!isFinite(c)||Math.abs(c-n.pos)<.5||(C++,rt(e,{template:t[0],display:n.display,attrs:[r],from:n.pos,to:x(c),duration:u,ease:d}),g&&i.length&&isFinite(a[s])&&rt(e,{template:i[0],attrs:o,from:a[s],to:x(f.toNew(a[s])),duration:u,ease:d}))})}function ot(e){let t=e.globals,n=t.prevChromeFrame;if(t.prevChromeFrame=null,!n||!t.axisCharts||!Environment.isBrowser()||!Ie(e)||!(e.seriesData.series||[]).some((t,n)=>Ve(e,n,!0,!0)!==null))return;let r=e.dom.baseEl;if(!_.elementExists(r))return;let i=Math.max(1,e.config.chart.animations.dynamicAnimation.speed||1),a=He(e);try{let t=[...r.querySelectorAll(qe)],o=Qe(n.xScale,Xe(e)),s=$e(n.yAnchors,Ze(e,t.map(e=>({pos:parseFloat(e.getAttribute(`y`)||``)}))));at(e,{newLabels:[...r.querySelectorAll(Ke)],oldLabels:n.xLabels,posAttr:`x`,newLines:[...r.querySelectorAll(Je)],oldLines:n.vGrid,lineAttrs:[`x1`,`x2`],duration:i,ease:a,project:o}),at(e,{newLabels:t,oldLabels:n.yLabels,posAttr:`y`,newLines:[...r.querySelectorAll(Ye)],oldLines:n.hGrid,lineAttrs:[`y1`,`y2`],duration:i,ease:a,project:s})}catch(e){}}const st=`.apexcharts-data-labels[data\\:dlKey]`,ct=`.apexcharts-datalabel`,lt=`.apexcharts-datalabel-total[data\\:dlTotalKey]`;function ut(e){var t,n;let r=e.config.dataLabels;return!!((t=r==null?void 0:r.animate)!=null&&t.enabled||(n=r==null?void 0:r.countUp)!=null&&n.enabled)}function dt(e){if(!isFinite(e))return 0;let t=String(Math.abs(e)),n=t.indexOf(`e`);if(n!==-1){let e=t.slice(0,n),r=parseInt(t.slice(n+1),10),i=e.indexOf(`.`),a=i===-1?0:e.length-i-1;return Math.min(6,Math.max(0,a-r))}let r=t.indexOf(`.`);return r===-1?0:Math.min(6,t.length-r-1)}function ft(e,t){let n=e.querySelector(`tspan`);n?n.textContent=t:e.textContent=t}function pt(e){let t=e.globals;if(t.prevDataLabels=null,!t.axisCharts||!Environment.isBrowser()||!ut(e))return;let n=e.dom.baseEl;if(_.elementExists(n))try{let e=/* @__PURE__ */ new Map;n.querySelectorAll(st).forEach(t=>{let n=t.getAttribute(`data:dlKey`);if(!n)return;let r=t.querySelector(ct);r&&e.set(n,{cx:parseFloat(r.getAttribute(`cx`)||``),cy:parseFloat(r.getAttribute(`cy`)||``),val:parseFloat(t.getAttribute(`data:dlVal`)||``)})}),n.querySelectorAll(lt).forEach(t=>{let n=t.getAttribute(`data:dlTotalKey`);n&&e.set(`total::${n}`,{cx:parseFloat(t.getAttribute(`cx`)||``),cy:parseFloat(t.getAttribute(`cy`)||``),val:parseFloat(t.getAttribute(`data:dlTotalVal`)||``)})}),t.prevDataLabels=e.size?e:null}catch(e){t.prevDataLabels=null}}function mt(e,t,n,r){let i=t.style;i.opacity=`0`,K(e,n,r,e=>{i.opacity=String(e)},()=>{i.opacity=``})}function ht(e,{el:t,oldCx:n,oldCy:r,duration:i,ease:a,delay:o=0}){let s=t.hasAttribute(`cx`)?t:t.querySelector(ct);if(!s)return;let c=n-parseFloat(s.getAttribute(`cx`)||``),u=r-parseFloat(s.getAttribute(`cy`)||``);if(!isFinite(c)||!isFinite(u)||Math.abs(c)+Math.abs(u)<=.5)return;let d=t.getAttribute(`transform`)||``,f=()=>K(e,i,a,e=>{let n=1-e;t.setAttribute(`transform`,`translate(${c*n} ${u*n}) ${d}`.trim())},()=>{d?t.setAttribute(`transform`,d):t.removeAttribute(`transform`)});o>0?(t.setAttribute(`transform`,`translate(${c} ${u}) ${d}`.trim()),setTimeout(()=>{e.globals.isDestroyed||f()},o)):f()}function gt(e,{el:t,from:n,to:r,formatter:i,fmtOpts:a,duration:o,ease:s,delay:c=0}){if(!isFinite(n)||!isFinite(r)||Math.abs(r-n)<=1e-9)return;let u=Math.max(dt(n),dt(r)),d=e=>{let t=Number(e.toFixed(u)),n=t;if(typeof i==`function`)try{n=i(t,a)}catch(e){n=t}return String(n)},f=()=>K(e,o,s,e=>{ft(t,d(n+(r-n)*e))},()=>{ft(t,d(r))});c>0?(ft(t,d(n)),setTimeout(()=>{e.globals.isDestroyed||f()},c)):f()}function _t(e){var t,n;let r=e.globals,i=r.prevDataLabels;if(r.prevDataLabels=null,!i||!r.axisCharts||!Environment.isBrowser()||!ut(e)||!Ie(e))return;let a=e.dom.baseEl;if(!_.elementExists(a))return;let o=e.config.dataLabels,u=!!((t=o.animate)!=null&&t.enabled),d=!!((n=o.countUp)!=null&&n.enabled),f=o.formatter,p=Math.max(1,e.config.chart.animations.dynamicAnimation.speed||1),m=He(e);try{a.querySelectorAll(st).forEach(t=>{let n=t.getAttribute(`data:dlKey`);if(!n)return;let r=t.querySelector(ct);if(!r)return;let a=i.get(n),o=parseInt(t.getAttribute(`data:dlDelay`)||`0`,10)||0;if(u&&(a&&isFinite(a.cx)&&isFinite(a.cy)?ht(e,{el:t,oldCx:a.cx,oldCy:a.cy,duration:p,ease:m,delay:o}):a||mt(e,t,p,m)),d&&a){let i=parseInt(n,10),u=parseInt(t.getAttribute(`data:dlJ`)||``,10);gt(e,{el:r,from:a.val,to:parseFloat(t.getAttribute(`data:dlVal`)||``),formatter:f,fmtOpts:c(s({},e),{seriesIndex:i,dataPointIndex:isFinite(u)?u:0,w:e}),duration:p,ease:m,delay:o})}});let t=e.config.plotOptions.bar.dataLabels.total.formatter||f;a.querySelectorAll(lt).forEach(n=>{let r=n.getAttribute(`data:dlTotalKey`);if(!r)return;let a=i.get(`total::${r}`);if(!a)return;let o=parseInt(n.getAttribute(`data:dlDelay`)||`0`,10)||0;if(u&&isFinite(a.cx)&&isFinite(a.cy)&&ht(e,{el:n,oldCx:a.cx,oldCy:a.cy,duration:p,ease:m,delay:o}),d){let i=parseInt(n.getAttribute(`data:dlTotalSeries`)||r,10);gt(e,{el:n,from:a.val,to:parseFloat(n.getAttribute(`data:dlTotalVal`)||``),formatter:t,fmtOpts:c(s({},e),{seriesIndex:i,dataPointIndex:0,w:e}),duration:p,ease:m,delay:o})}})}catch(e){}}class Series{constructor(e,{toggleDataSeries:t=void 0,revertDefaultAxisMinMax:n=void 0,updateSeries:r=void 0}={}){this.w=e,this._toggleDataSeries=t||null,this._revertDefaultAxisMinMax=n||null,this._updateSeries=r||null,this.legendInactiveClass=`legend-mouseover-inactive`}clearSeriesCache(){let e=this.w;e.globals.cachedSelectors&&(delete e.globals.cachedSelectors.allSeriesEls,delete e.globals.cachedSelectors.highlightSeriesEls)}getAllSeriesEls(){let e=this.w,t=`allSeriesEls`;return e.globals.cachedSelectors[t]||(e.globals.cachedSelectors[t]=e.dom.baseEl.getElementsByClassName(`apexcharts-series`)),e.globals.cachedSelectors[t]}getSeriesByName(e){return this.w.dom.baseEl.querySelector(`.apexcharts-inner .apexcharts-series[seriesName='${_.escapeString(e)}']`)}isSeriesHidden(e){var t;let n=this.getSeriesByName(e),r=parseInt((t=n.getAttribute(`data:realIndex`))==null?`0`:t,10);return{isHidden:n.classList.contains(`apexcharts-series-collapsed`),realIndex:r}}addCollapsedClassToSeries(e,t){Series.addCollapsedClassToSeries(this.w,e,t)}static addCollapsedClassToSeries(e,t,n){let r=!1;function i(e){for(let i=0;i<e.length;i++)e[i].index===n&&(t.node.classList.add(`apexcharts-series-collapsed`),r=!0)}if(i(e.globals.collapsedSeries),i(e.globals.ancillaryCollapsedSeries),!r||(e.globals.collapsingSeriesIndices||[]).indexOf(n)===-1||(t.node.classList.add(`apexcharts-series-collapsing`),!Environment.isBrowser()))return;let a=e.config.chart.animations,o=(a.dynamicAnimation.speed||0)+(a.speed||0)+100;setTimeout(()=>{e.globals.isDestroyed||t.node.classList.remove(`apexcharts-series-collapsing`)},o)}toggleSeries(e){var t;let n=this.isSeriesHidden(e);return(t=this._toggleDataSeries)==null||t.call(this,n.realIndex,n.isHidden),n.isHidden}showSeries(e){var t;let n=this.isSeriesHidden(e);n.isHidden&&((t=this._toggleDataSeries)==null||t.call(this,n.realIndex,!0))}hideSeries(e){var t;let n=this.isSeriesHidden(e);n.isHidden||(t=this._toggleDataSeries)==null||t.call(this,n.realIndex,!1)}prepareDataUpdate(){let e=this.w;this.clearSeriesCache(),e.globals.previousPaths=[],e.globals.axisCharts||(e.globals.collapsedSeries=[],e.globals.ancillaryCollapsedSeries=[],e.globals.collapsedSeriesIndices=[],e.globals.ancillaryCollapsedSeriesIndices=[])}resetSeries(e=!0,t=!0,n=!0){var r,i;let a=this.w;this.clearSeriesCache();let o=_.clone(a.globals.initialSeries);Array.isArray(o)||(o=_.clone(a.config.series)||[]),a.globals.previousPaths=[],n?(a.globals.collapsedSeries=[],a.globals.ancillaryCollapsedSeries=[],a.globals.collapsedSeriesIndices=[],a.globals.ancillaryCollapsedSeriesIndices=[]):o=this.emptyCollapsedSeries(o),a.config.series=o,e&&(t&&(a.interact.zoomed=!1,(r=this._revertDefaultAxisMinMax)==null||r.call(this)),(i=this._updateSeries)==null||i.call(this,o,a.config.chart.animations.dynamicAnimation.enabled))}emptyCollapsedSeries(e){let t=this.w;if(!Array.isArray(e))return e;for(let n=0;n<e.length;n++)t.globals.collapsedSeriesIndices.indexOf(n)>-1&&(e[n]&&typeof e[n]==`object`?e[n].data=[]:e[n]=0);return e}_deriveSeriesNames(e){let t=this.w,n=e||t.config.series||[],r=t.config.labels||[];return n.map((e,t)=>e&&typeof e==`object`&&e.name!=null?String(e.name):r[t]==null?`series-${t+1}`:String(r[t]))}reconcileCollapsedByName(e){let t=this.w,n=t.globals,r=e||t.config.series,i=this._deriveSeriesNames(r),a=e=>{let t=[],a=[];return e.forEach(e=>{let o=e&&e.name!=null?i.indexOf(e.name):e.index;if(o==null||o<0||o>=r.length)return;let s=r[o];e.index=o,n.axisCharts?s&&Array.isArray(s.data)&&s.data.length&&(e.data=s.data.slice()):e.data=s,t.push(e),a.push(o)}),{records:t,indices:a}},o=a(n.collapsedSeries);n.collapsedSeries=o.records,n.collapsedSeriesIndices=o.indices;let s=a(n.ancillaryCollapsedSeries);n.ancillaryCollapsedSeries=s.records,n.ancillaryCollapsedSeriesIndices=s.indices,n.allSeriesCollapsed=n.collapsedSeries.length+n.ancillaryCollapsedSeries.length===r.length,this.emptyCollapsedSeries(r)}canvasRestyle(e){let t=this.w.globals.activeRenderer;t&&t.kind===`canvas`&&typeof t.restyle==`function`&&t.restyle(e)}highlightSeries(e){var t;let n=this.w,r=this.getSeriesByName(e),i=parseInt((t=r==null?void 0:r.getAttribute(`data:realIndex`))==null?``:t,10),a=`highlightSeriesEls`,o=n.globals.cachedSelectors[a];o||(o=n.dom.baseEl.querySelectorAll(`.apexcharts-series, .apexcharts-datalabels, .apexcharts-yaxis`),n.globals.cachedSelectors[a]=o);let s=null,c=null,u=null;if(n.globals.axisCharts||n.config.chart.type===`radialBar`)if(n.globals.axisCharts){s=n.dom.baseEl.querySelector(`.apexcharts-series[data\\:realIndex='${i}']`),c=n.dom.baseEl.querySelector(`.apexcharts-datalabels[data\\:realIndex='${i}']`);let e=n.globals.seriesYAxisReverseMap[i];u=n.dom.baseEl.querySelector(`.apexcharts-yaxis[rel='${e}']`)}else s=n.dom.baseEl.querySelector(`.apexcharts-series[rel='${i+1}']`);else s=n.dom.baseEl.querySelector(`.apexcharts-series[rel='${i+1}'] path`);for(let e=0;e<o.length;e++)o[e].classList.add(this.legendInactiveClass);if(s){if(!n.globals.axisCharts){let e=s.parentNode;e==null||e.classList.remove(this.legendInactiveClass)}s.classList.remove(this.legendInactiveClass),c!==null&&c.classList.remove(this.legendInactiveClass),u!==null&&u.classList.remove(this.legendInactiveClass)}else for(let e=0;e<o.length;e++)o[e].classList.remove(this.legendInactiveClass);this.canvasRestyle(s&&!Number.isNaN(i)?{active:i,opacity:.2}:null)}toggleSeriesOnHover(e,t){let n=this.w;t||(t=e.target);let r=n.dom.baseEl.querySelectorAll(`.apexcharts-series, .apexcharts-datalabels, .apexcharts-yaxis`);if(e.type===`mousemove`){let e=parseInt(t.getAttribute(`rel`),10)-1;this.highlightSeries(n.seriesData.seriesNames[e])}else if(e.type===`mouseout`){for(let e=0;e<r.length;e++)r[e].classList.remove(this.legendInactiveClass);this.canvasRestyle(null)}}highlightRangeInSeries(e,t){let n=this.w,r=n.dom.baseEl.getElementsByClassName(`apexcharts-heatmap-rect`),i=e=>{for(let t=0;t<r.length;t++){let n=r[t].classList;typeof n[e]==`function`&&n[e](this.legendInactiveClass)}};if(t===`reset`){i(`remove`);return}let a=n.config.plotOptions.heatmap.colorScale.ranges,o=a&&a[e];if(o){i(`add`);for(let e=0;e<r.length;e++){let t=Number(r[e].getAttribute(`val`));t>=o.from&&t<=o.to&&r[e].classList.remove(this.legendInactiveClass)}}}getActiveConfigSeriesIndex(e=`asc`,t=[]){let n=this.w,r=0;if(n.config.series.length>1){let i=n.config.series.map((e,r)=>{let i=()=>n.globals.comboCharts?t.length===0||t.length&&t.indexOf(n.config.series[r].type)>-1:!0;return e.data&&e.data.length>0&&n.globals.collapsedSeriesIndices.indexOf(r)===-1&&i()?r:-1});for(let t=e===`asc`?0:i.length-1;e===`asc`?t<i.length:t>=0;e===`asc`?t++:t--)if(i[t]!==-1){r=i[t];break}}return r}getActiveConfigSeriesIndexByGroup(e=[]){let t=this.w;return(t.labelData.seriesGroups||[]).map(n=>{let r=-1;return t.config.series.forEach((i,a)=>{n.indexOf(t.seriesData.seriesNames[a])===-1||t.globals.comboCharts&&e.length&&e.indexOf(i.type)===-1||i.data&&i.data.length>0&&t.globals.collapsedSeriesIndices.indexOf(a)===-1&&(r=a)}),r})}getBarSeriesIndices(){return this.w.globals.comboCharts?this.w.config.series.map((e,t)=>e.type===`bar`||e.type===`column`?t:-1).filter(e=>e!==-1):this.w.config.series.map((e,t)=>t)}getPreviousPaths(){var e,t,n,r;let i=this.w;if(Pe(i),et(i),pt(i),!i.globals.axisCharts){i.globals.previousPaths=i.seriesData.series;return}if(!_.elementExists(i.dom.baseEl)){i.globals.previousPaths=[];return}i.globals.previousPaths=[];function a(e,t,n){let r=e[t].childNodes,a={type:n,paths:[],realIndex:e[t].getAttribute(`data:realIndex`)};for(let e=0;e<r.length;e++)if(r[e].hasAttribute(`pathTo`)){let t=r[e].getAttribute(`pathTo`);a.paths.push({d:t,key:r[e].getAttribute(`data:pathKey`),fill:r[e].getAttribute(`fill`),flip:r[e].classList.contains(`apexcharts-flip-y`)||r[e].classList.contains(`apexcharts-flip-x`)})}i.globals.previousPaths.push(a)}let o=e=>i.dom.baseEl.querySelectorAll(`.apexcharts-${e}-series .apexcharts-series`);[`line`,`area`,`bar`,`rangebar`,`rangeArea`,`candlestick`,`radar`].forEach(e=>{let t=o(e);for(let n=0;n<t.length;n++)a(t,n,e)});let s=i.dom.baseEl.querySelectorAll(`.apexcharts-${i.config.chart.type} .apexcharts-series`);if(s.length>0)for(let a=0;a<s.length;a++){let o=`.apexcharts-${i.config.chart.type} .apexcharts-series[data\\:realIndex='${a}']`,s=i.dom.baseEl.querySelectorAll(`${o} rect, ${o} path.apexcharts-heatmap-rect`),c=[];for(let i=0;i<s.length;i++){let a=e=>s[i].getAttribute(e),o={x:parseFloat((e=a(`x`))==null?`0`:e),y:parseFloat((t=a(`y`))==null?`0`:t),width:parseFloat((n=a(`width`))==null?`0`:n),height:parseFloat((r=a(`height`))==null?`0`:r)};c.push({rect:o,color:s[i].getAttribute(`color`)})}i.globals.previousPaths.push(c)}}clearPreviousPaths(){let e=this.w;e.globals.previousPaths=[],e.globals.allSeriesCollapsed=!1}handleNoData(){let e=this.w,t=this,n=e.config.noData,r=new Graphics(t.w),i=e.globals.svgWidth/2,a=e.globals.svgHeight/2,o=`middle`;if(e.globals.noData=!0,e.globals.animationEnded=!0,n.align===`left`?(i=10,o=`start`):n.align===`right`&&(i=e.globals.svgWidth-10,o=`end`),n.verticalAlign===`top`?a=50:n.verticalAlign===`bottom`&&(a=e.globals.svgHeight-50),i+=n.offsetX,a=a+parseInt(n.style.fontSize,10)+2+n.offsetY,n.text!==void 0&&n.text!==``){let t=r.drawText({x:i,y:a,text:n.text,textAnchor:o,fontSize:n.style.fontSize,fontFamily:n.style.fontFamily,foreColor:n.style.color,opacity:1,cssClass:`apexcharts-text-nodata`});e.dom.Paper.add(t)}}setNullSeriesToZeroValues(e){let t=this.w;for(let n=0;n<e.length;n++)if(e[n].length===0)for(let r=0;r<e[t.globals.maxValsInArrayIndex].length;r++)e[n].push(0);return e}hasAllSeriesEqualX(){let e=!0,t=this.w,n=this.filteredSeriesX();for(let t=0;t<n.length-1;t++)if(n[t][0]!==n[t+1][0]){e=!1;break}return t.globals.allSeriesHasEqualX=e,e}filteredSeriesX(){return this.w.seriesData.seriesX.map(e=>e.length>0?e:[])}}const vt={accent:`--apx-accent`,fore:`--apx-fore`,grid:`--apx-grid`,surface:`--apx-surface`},yt=24;function bt(e){if(!Environment.isBrowser())return{};let t=e.dom&&(e.dom.elWrap||e.dom.baseEl)||null;if(!t)return{};let n=BrowserAPIs.getComputedStyle(t);if(!n||typeof n.getPropertyValue!=`function`)return{};let r=e=>{let t=n.getPropertyValue(e);return t?String(t).trim():``},i={};for(let e in vt){let t=r(vt[e]);t&&(i[e]=t)}let a=[];for(let e=1;e<=24;e++){let t=r(`--apx-series-${e}`);if(!t)break;a.push(t)}return a.length&&(i.series=a),i}const xt=`__apexcharts_themes__`;globalThis[xt]||(globalThis[xt]={});function St(){return globalThis[xt]}function Ct(e,t){if(!e||typeof e!=`string`){console.warn(`ApexCharts: registerTheme requires a non-empty name.`);return}if(t!=null&&(typeof t!=`object`||Array.isArray(t))){console.warn(`ApexCharts: registerTheme("${e}") expects an object like { mode, palette, tokens, monochrome, accessibility }.`);return}St()[e]=t||{}}function wt(e){return e&&St()[e]||null}function Tt(e){e&&delete St()[e]}const Et=`#373d3f`,Dt=`#f6f7f8`,Ot=`#e0e0e0`;class Theme{constructor(e){this.w=e,this.colors=[],this.isColorFn=!1,this.isHeatmapDistributed=this.checkHeatmapDistributed(),this.isBarDistributed=this.checkBarDistributed(),this._tokens={},this._namedTheme=null}checkHeatmapDistributed(){let{chart:e,plotOptions:t}=this.w.config;return e.type===`treemap`&&t.treemap&&t.treemap.distributed||e.type===`heatmap`&&t.heatmap&&t.heatmap.distributed}checkBarDistributed(){let{chart:e,plotOptions:t}=this.w.config;return t.bar&&t.bar.distributed&&(e.type===`bar`||e.type===`rangeBar`)}init(){this.setDefaultColors()}setDefaultColors(){var e;let t=this.w,n=new _;this._namedTheme=wt(t.config.theme.name),this._applyNamedThemeMode(),t.dom.elWrap.classList.add(`apexcharts-theme-${t.config.theme.mode||`light`}`),this._applyModeDefaults(),this._tokens=this._resolveTokens(),this.applyTokenChrome(this._tokens);let r=(e=t.config.theme.accessibility)==null?void 0:e.colorBlindMode;if(r){t.globals.colors=this.getColorBlindColors(r),this.applySeriesColors(t.seriesData.seriesColors,t.globals.colors);let e=t.globals.colors.slice();this.pushExtraColors(t.globals.colors),this.applyColorTypes([`fill`,`stroke`],e),this.applyDataLabelsColors(e),this.applyRadarPolygonsColors(),this.applyMarkersColors(e),r===`highContrast`&&t.dom.elWrap.classList.add(`apexcharts-high-contrast`);return}let i=[...t.config.colors||t.config.fill.colors||[]];t.globals.colors=this.getColors(i),this.applySeriesColors(t.seriesData.seriesColors,t.globals.colors),t.config.theme.monochrome.enabled&&(t.globals.colors=this.getMonochromeColors(t.config.theme.monochrome,t.seriesData.series,n));let a=t.globals.colors.slice();this.pushExtraColors(t.globals.colors),this.applyColorTypes([`fill`,`stroke`],a),this.applyDataLabelsColors(a),this.applyRadarPolygonsColors(),this.applyMarkersColors(a)}_applyModeDefaults(){let e=this.w,t=e.config.theme.mode;t===`dark`?(e.config.chart.foreColor===Et&&(e.config.chart.foreColor=Dt),e.config.theme.palette===`palette1`&&(e.config.theme.palette=`palette4`),e.config.tooltip&&e.config.tooltip.theme!==`light`&&(e.config.tooltip.theme=`dark`)):t===`light`&&(e.config.chart.foreColor===Dt&&(e.config.chart.foreColor=Et),e.config.theme.palette===`palette4`&&(e.config.theme.palette=`palette1`))}_applyNamedThemeMode(){let e=this._namedTheme;if(!e)return;let t=this.w.config.theme;e.mode&&!t.mode&&(t.mode=e.mode),e.accessibility&&e.accessibility.colorBlindMode&&!(t.accessibility&&t.accessibility.colorBlindMode)&&(t.accessibility=t.accessibility||{},t.accessibility.colorBlindMode=e.accessibility.colorBlindMode),e.monochrome&&e.monochrome.enabled&&!t.monochrome.enabled&&(t.monochrome=s(s({},t.monochrome),e.monochrome))}_resolveTokens(){let e=this._namedTheme&&this._namedTheme.tokens||{},t=this._shouldUseTokens()?bt(this.w):{};return s(s({},e),t)}_shouldUseTokens(){return this.w.config.theme.tokens!==!1}applyTokenChrome(e){if(!e)return;let t=this.w;if(e.fore&&(t.config.chart.foreColor===Et||t.config.chart.foreColor===Dt)&&(t.config.chart.foreColor=e.fore),e.grid){t.config.grid.borderColor===Ot&&(t.config.grid.borderColor=e.grid);let n=t=>{t&&(t.axisBorder&&t.axisBorder.color===Ot&&(t.axisBorder.color=e.grid),t.axisTicks&&t.axisTicks.color===Ot&&(t.axisTicks.color=e.grid))};n(t.config.xaxis),Array.isArray(t.config.yaxis)?t.config.yaxis.forEach(n):n(t.config.yaxis)}let n=t.globals.tokenSurface,r=t.config.chart.background,i=!r||r===n;if(e.surface){if(i){t.config.chart.background=e.surface,t.globals.tokenSurface=e.surface;let n=t.dom.Paper&&t.dom.Paper.node;n&&n.style&&(n.style.background=e.surface)}}else if(n&&r===n){t.config.chart.background=``,t.globals.tokenSurface=void 0;let e=t.dom.Paper&&t.dom.Paper.node;e&&e.style&&(e.style.background=``)}}getColors(e){let t=this.w;return!e||e.length===0?this.predefined():Array.isArray(e)&&e.length>0&&typeof e[0]==`function`?(this.isColorFn=!0,t.config.series.map((n,r)=>{let i=e[r]||e[0];return typeof i==`function`?i({value:t.globals.axisCharts?t.seriesData.series[r][0]||0:t.seriesData.series[r],seriesIndex:r,dataPointIndex:r,w:this.w}):i})):e}applySeriesColors(e,t){e.forEach((e,n)=>{e&&(t[n]=e)})}getMonochromeColors(e,t,n){let{color:r,shadeIntensity:i,shadeTo:a}=e,o=this.isBarDistributed||this.isHeatmapDistributed?t[0].length*t.length:t.length,s=1/(o/i),c=0;return Array.from({length:o},()=>{let e=a===`dark`?n.shadeColor(c*-1,r):n.shadeColor(c,r);return c+=s,e})}applyColorTypes(e,t){let n=this.w;e.forEach(e=>{n.globals[e].colors=n.config[e].colors===void 0?this.isColorFn?n.config.colors:t:n.config[e].colors.slice(),this.pushExtraColors(n.globals[e].colors)})}applyDataLabelsColors(e){let t=this.w;t.globals.dataLabels.style.colors=t.config.dataLabels.style.colors===void 0?e:t.config.dataLabels.style.colors.slice(),this.pushExtraColors(t.globals.dataLabels.style.colors,50)}applyRadarPolygonsColors(){let e=this.w;e.globals.radarPolygons.fill.colors=e.config.plotOptions.radar.polygons.fill.colors===void 0?[e.config.theme.mode===`dark`?`#343A3F`:`none`]:e.config.plotOptions.radar.polygons.fill.colors.slice(),this.pushExtraColors(e.globals.radarPolygons.fill.colors,20)}applyMarkersColors(e){let t=this.w;t.globals.markers.colors=t.config.markers.colors===void 0?e:t.config.markers.colors.slice(),this.pushExtraColors(t.globals.markers.colors)}pushExtraColors(e,t,n=null){let r=this.w,i=t||r.seriesData.series.length;if(n===null&&(n=this.isBarDistributed||this.isHeatmapDistributed||r.config.chart.type===`heatmap`&&r.config.plotOptions.heatmap&&r.config.plotOptions.heatmap.colorScale.inverse),n&&r.seriesData.series.length&&(i=r.seriesData.series[r.globals.maxValsInArrayIndex].length*r.seriesData.series.length),e.length<i){let t=i-e.length;for(let n=0;n<t;n++)e.push(e[n])}}getColorBlindColors(e){let t=Me();return({deuteranopia:t.cvdDeuteranopia,protanopia:t.cvdProtanopia,tritanopia:t.cvdTritanopia,highContrast:t.highContrast}[e]||t.palette1).slice()}updateThemeOptions(e){e.chart=e.chart||{},e.tooltip=e.tooltip||{};let t=e.theme.mode,n=t===`dark`?`palette4`:t===`light`?`palette1`:e.theme.palette||`palette1`,r=t===`dark`?`#f6f7f8`:t===`light`?`#373d3f`:e.chart.foreColor||`#373d3f`;return e.tooltip.theme=t||`light`,e.chart.foreColor=r,e.theme.palette=n,e}predefined(){let e=this.w.config.theme.palette,t=Me(),n=t[e]||t.palette1,r=this._tokens||{};if(Array.isArray(r.series)&&r.series.length)return r.series.slice();if(r.accent)return[r.accent,...n];let i=this._namedTheme;return i&&Array.isArray(i.palette)&&i.palette.length?i.palette.slice():n}}class TitleSubtitle{constructor(e){this.w=e}draw(){this.drawTitleSubtitle(`title`),this.drawTitleSubtitle(`subtitle`)}drawTitleSubtitle(e){let t=this.w,n=e===`title`?t.config.title:t.config.subtitle,r=t.globals.svgWidth/2,i=n.offsetY,a=`middle`;if(n.align===`left`?(r=10,a=`start`):n.align===`right`&&(r=t.globals.svgWidth-10,a=`end`),r+=n.offsetX,i=i+parseInt(n.style.fontSize,10)+n.margin/2,n.text!==void 0){let o=new Graphics(this.w).drawText({x:r,y:i,text:n.text,textAnchor:a,fontSize:n.style.fontSize,fontFamily:n.style.fontFamily,fontWeight:n.style.fontWeight,foreColor:n.style.color,opacity:1});o.node.setAttribute(`class`,`apexcharts-${e}-text`),t.dom.Paper.add(o)}}}class Helpers{constructor(e){this.w=e.w,this.dCtx=e}getTitleSubtitleCoords(e){let t=this.w,n=0,r=0,i=e===`title`?t.config.title.floating:t.config.subtitle.floating,a=t.dom.baseEl.querySelector(`.apexcharts-${e}-text`);if(a!==null&&!i){let e=a.getBoundingClientRect();n=e.width,r=t.globals.axisCharts?e.height+5:e.height}return{width:n,height:r}}getLegendsRect(){let e=this.w,t=e.dom.elLegendWrap;!e.config.legend.height&&(e.config.legend.position===`top`||e.config.legend.position===`bottom`)&&t&&(t.style.maxHeight=e.globals.svgHeight/2+`px`);let n=Object.assign({},_.getBoundingClientRect(t));return t!==null&&!e.config.legend.floating&&e.config.legend.show?this.dCtx.lgRect={x:n.x,y:n.y,height:n.height,width:n.height===0?0:n.width}:this.dCtx.lgRect={x:0,y:0,height:0,width:0},(e.config.legend.position===`left`||e.config.legend.position===`right`)&&this.dCtx.lgRect.width*1.5>e.globals.svgWidth&&(this.dCtx.lgRect.width=e.globals.svgWidth/1.5),this.dCtx.lgRect}getDatalabelsRect(){let e=this.w,t=[];e.config.series.forEach((n,r)=>{n.data.forEach((n,i)=>{let a=t=>e.config.dataLabels.formatter(t,{seriesIndex:r,dataPointIndex:i,w:e}),o=a(e.seriesData.series[r][i]);t.push(o)})});let n=_.getLargestStringFromArr(t),r=new Graphics(this.w),i=e.config.dataLabels.style,a=r.getTextRects(n,parseInt(i.fontSize).toString(),i.fontFamily);return{width:a.width*1.05,height:a.height}}getLargestStringFromMultiArr(e,t){let n=this.w,r=e;if(n.axisFlags.isMultiLineX){let e=t.map(e=>Array.isArray(e)?e.length:1),n=Math.max(...e);r=t[e.indexOf(n)]}return r}getSparklineStrokeInset(){let e=this.w,t=Array.isArray(e.config.stroke.width)?Math.max(...e.config.stroke.width):e.config.stroke.width,n=t/2;if(!e.config.stroke.show||!(n>0))return{top:0,bottom:0};let r=e.globals.maxY-e.globals.minY,i=this._getSeriesYExtremes();if(!this._strokeTracesDataPoints()||!(r>0)||!i)return{top:n,bottom:n};let a=Math.max(e.globals.svgHeight-t,0),o=a*(e.globals.maxY-i.max)/r,s=a*(i.min-e.globals.minY)/r;return{top:Math.min(Math.max(n-o,0),n),bottom:Math.min(Math.max(n-s,0),n)}}_strokeTracesDataPoints(){let e=this.w;if(!e.globals.axisCharts||e.config.chart.stacked)return!1;let t=[`line`,`area`,`scatter`];return e.config.series.every(n=>t.includes(n.type||e.config.chart.type))}_getSeriesYExtremes(){let e=1/0,t=-1/0;return this.w.seriesData.series.forEach(n=>{Array.isArray(n)&&n.forEach(n=>{Number.isFinite(n)&&(n<e&&(e=n),n>t&&(t=n))})}),e===1/0?null:{min:e,max:t}}}class DimXAxis{constructor(e){this.w=e.w,this.dCtx=e}getxAxisLabelsCoords(){let e=this.w,t=e.labelData.labels.slice();e.config.xaxis.convertedCatToNumeric&&t.length===0&&(t=e.labelData.categoryLabels);let n;if(e.labelData.timescaleLabels.length>0){let t=this.getxAxisTimeScaleLabelsCoords();n={width:t.width,height:t.height},e.layout.rotateXLabels=!1}else{this.dCtx.lgWidthForSideLegends=(e.config.legend.position===`left`||e.config.legend.position===`right`)&&!e.config.legend.floating?this.dCtx.lgRect.width:0;let r=e.formatters.xLabelFormatter,i=_.getLargestStringFromArr(t),a=this.dCtx.dimHelpers.getLargestStringFromMultiArr(i,t);e.globals.isBarHorizontal&&(i=e.globals.yAxisScale[0].result.reduce((e,t)=>e.length>t.length?e:t,0),a=i);let o=new Formatters(this.w),s=i;i=o.xLabelFormat(r,i,s,{i:void 0,dateFormatter:new DateTime(this.w).formatDate,w:e}),a=o.xLabelFormat(r,a,s,{i:void 0,dateFormatter:new DateTime(this.w).formatDate,w:e}),(e.config.xaxis.convertedCatToNumeric&&i===void 0||String(i).trim()===``)&&(i=`1`,a=i);let c=new Graphics(this.w),u=c.getTextRects(i,e.config.xaxis.labels.style.fontSize),d=u;if(i!==a&&(d=c.getTextRects(a,e.config.xaxis.labels.style.fontSize)),n={width:u.width>=d.width?u.width:d.width,height:u.height>=d.height?u.height:d.height},n.width*t.length>e.globals.svgWidth-this.dCtx.lgWidthForSideLegends-this.dCtx.yAxisWidth-this.dCtx.gridPad.left-this.dCtx.gridPad.right&&e.config.xaxis.labels.rotate!==0||e.config.xaxis.labels.rotateAlways){if(!e.globals.isBarHorizontal){e.layout.rotateXLabels=!0;let t=t=>c.getTextRects(t,e.config.xaxis.labels.style.fontSize,e.config.xaxis.labels.style.fontFamily,`rotate(${e.config.xaxis.labels.rotate} 0 0)`,!1);u=t(i),i!==a&&(d=t(a)),n.height=(u.height>d.height?u.height:d.height)/1.5,n.width=u.width>d.width?u.width:d.width}}else e.layout.rotateXLabels=!1}return e.config.xaxis.labels.show||(n={width:0,height:0}),{width:n.width,height:n.height}}getxAxisGroupLabelsCoords(){var e;let t=this.w;if(!t.labelData.hasXaxisGroups)return{width:0,height:0};let n=((e=t.config.xaxis.group.style)==null?void 0:e.fontSize)||t.config.xaxis.labels.style.fontSize,r=t.labelData.groups.map(e=>e.title),i,a=_.getLargestStringFromArr(r),o=this.dCtx.dimHelpers.getLargestStringFromMultiArr(a,r),s=new Graphics(this.w),c=s.getTextRects(a,n),u=c;return a!==o&&(u=s.getTextRects(o,n)),i={width:c.width>=u.width?c.width:u.width,height:c.height>=u.height?c.height:u.height},t.config.xaxis.labels.show||(i={width:0,height:0}),{width:i.width,height:i.height}}getxAxisTitleCoords(){let e=this.w,t=0,n=0;if(e.config.xaxis.title.text!==void 0){let r=new Graphics(this.w).getTextRects(e.config.xaxis.title.text,e.config.xaxis.title.style.fontSize);t=r.width,n=r.height}return{width:t,height:n}}getxAxisTimeScaleLabelsCoords(){let e=this.w;this.dCtx.timescaleLabels=e.labelData.timescaleLabels.slice();let t=this.dCtx.timescaleLabels.map(e=>e.value),n=t.reduce((e,t)=>e===void 0?(console.error(`You have possibly supplied invalid Date format. Please supply a valid JavaScript Date`),0):e.length>t.length?e:t,0),r=new Graphics(this.w).getTextRects(n,e.config.xaxis.labels.style.fontSize);return r.width*1.05*t.length>e.layout.gridWidth&&e.config.xaxis.labels.rotate!==0&&(e.globals.overlappingXLabels=!0),r}additionalPaddingXLabels(e){let t=this.w,n=t.globals,r=t.config,i=r.xaxis.type,a=e.width;n.skipLastTimelinelabel=!1,n.skipFirstTimelinelabel=!1;let o=t.config.yaxis[0].opposite&&t.globals.isBarHorizontal,s=e=>n.collapsedSeriesIndices.indexOf(e)!==-1,c=e=>{if(this.dCtx.timescaleLabels&&this.dCtx.timescaleLabels.length){let i=this.dCtx.timescaleLabels[0],o=this.dCtx.timescaleLabels[this.dCtx.timescaleLabels.length-1].position+a/1.75-this.dCtx.yAxisWidthRight,s=i.position-a/1.75+this.dCtx.yAxisWidthLeft,c=t.config.legend.position===`right`&&this.dCtx.lgRect.width>0?this.dCtx.lgRect.width:0;o>n.svgWidth-t.layout.translateX-c&&(n.skipLastTimelinelabel=!0),s<-((!e.show||e.floating)&&(r.chart.type===`bar`||r.chart.type===`candlestick`||r.chart.type===`rangeBar`||r.chart.type===`boxPlot`||r.chart.type===`violin`)?a/1.75:10)&&(n.skipFirstTimelinelabel=!0)}else i===`datetime`?this.dCtx.gridPad.right<a&&!t.layout.rotateXLabels&&(n.skipLastTimelinelabel=!0):i!==`datetime`&&this.dCtx.gridPad.right<a/2-this.dCtx.yAxisWidthRight&&!t.layout.rotateXLabels&&!t.config.xaxis.labels.trim&&(this.dCtx.xPadRight=a/2+1)},u=(e,t)=>{r.yaxis.length>1&&s(t)||c(e)};r.yaxis.forEach((e,t)=>{o?(this.dCtx.gridPad.left<a&&(this.dCtx.xPadLeft=a/2+1),this.dCtx.xPadRight=a/2+1):u(e,t)})}}class DimYAxis{constructor(e){this.w=e.w,this.dCtx=e}getyAxisLabelsCoords(){let e=this.w,t=0,n=0,r=[],i=10,a=new AxesUtils(this.w,{theme:this.dCtx.theme,timeScale:this.dCtx.timeScale});return e.config.yaxis.map((t,n)=>{let o={seriesIndex:n,dataPointIndex:-1,w:e},s=e.globals.yAxisScale[n],c=0;if(!a.isYAxisHidden(n)&&t.labels.show&&t.labels.minWidth!==void 0&&(c=t.labels.minWidth),!a.isYAxisHidden(n)&&t.labels.show&&s.result.length){let a=e.formatters.yLabelFormatters[n],u=s.niceMin===Number.MIN_VALUE?0:s.niceMin,d=s.result.reduce((e,t)=>{var n,r;return((n=String(a(e,o)))==null?void 0:n.length)>((r=String(a(t,o)))==null?void 0:r.length)?e:t},u);d=a(d,o);let f=d;if((d===void 0||d.length===0)&&(d=s.niceMax),String(d).length===1&&(d+=`.0`,f=d),e.globals.isBarHorizontal){i=0;let t=e.labelData.labels.slice();d=_.getLargestStringFromArr(t),d=a(d,{seriesIndex:n,dataPointIndex:-1,w:e}),f=this.dCtx.dimHelpers.getLargestStringFromMultiArr(d,t)}let p=new Graphics(this.w),m=`rotate(${t.labels.rotate} 0 0)`,h=p.getTextRects(d,t.labels.style.fontSize,t.labels.style.fontFamily,m,!1),g=h;d!==f&&(g=p.getTextRects(f,t.labels.style.fontSize,t.labels.style.fontFamily,m,!1)),r.push({width:(c>g.width||c>h.width?c:g.width>h.width?g.width:h.width)+i,height:g.height>h.height?g.height:h.height})}else r.push({width:0,height:0})}),r}getyAxisTitleCoords(){let e=this.w,t=[];return e.config.yaxis.map(e=>{if(e.show&&e.title.text!==void 0){let n=new Graphics(this.w),r=`rotate(${e.title.rotate} 0 0)`,i=n.getTextRects(e.title.text,e.title.style.fontSize,e.title.style.fontFamily,r,!1);t.push({width:i.width,height:i.height})}else t.push({width:0,height:0})}),t}getTotalYAxisWidth(){let e=this.w,t=0,n=0,r=0,i=e.globals.yAxisScale.length>1?10:0,a=new AxesUtils(this.w,{theme:this.dCtx.theme,timeScale:this.dCtx.timeScale}),o=function(t){return e.globals.ignoreYAxisIndexes.indexOf(t)>-1},s=(s,c)=>{let u=e.config.yaxis[c].floating,d=0;s.width>0&&!u?(d=s.width+i,o(c)&&(d=d-s.width-i)):d=u||a.isYAxisHidden(c)?0:5,e.config.yaxis[c].opposite?r+=d:n+=d,t+=d};return e.layout.yLabelsCoords.map((e,t)=>{s(e,t)}),e.layout.yTitleCoords.map((e,t)=>{s(e,t)}),e.globals.isBarHorizontal&&!e.config.yaxis[0].floating&&(t=e.layout.yLabelsCoords[0].width+e.layout.yTitleCoords[0].width+15),this.dCtx.yAxisWidthLeft=n,this.dCtx.yAxisWidthRight=r,t}}class DimGrid{constructor(e){this.w=e.w,this.dCtx=e}gridPadForColumnsInNumericAxis(e){let{w:t}=this,{config:n,globals:r}=t;if(r.noData||r.collapsedSeries.length+r.ancillaryCollapsedSeries.length===n.series.length)return 0;let i=e=>[`bar`,`rangeBar`,`candlestick`,`boxPlot`,`violin`].includes(e),a=n.chart.type,o=0,s=i(a)?n.series.length:1;r.comboBarCount>0&&(s=r.comboBarCount),r.collapsedSeries.forEach(e=>{i(e.type)&&--s}),n.chart.stacked&&(s=1);let c=i(a)||r.comboBarCount>0,u=Math.abs(r.initialMaxX-r.initialMinX);if(c&&t.axisFlags.isXNumeric&&!r.isBarHorizontal&&s>0&&u!==0){u<=3&&(u=r.dataPoints);let t=u/e,i=r.minXDiff&&r.minXDiff/t>0?r.minXDiff/t:0;i>e/2&&(i/=2),o=i*parseInt(n.plotOptions.bar.columnWidth,10)/100,o<1&&(o=1),r.barPadForNumericAxis=o}return o}gridPadForStackedTotalDataLabels(){let{w:e}=this,t=e.config.plotOptions.bar.dataLabels.total;if(!e.globals.isBarHorizontal||!e.config.chart.stacked||e.config.chart.stackType!==`100%`||!t.enabled)return;let n=e.seriesData.stackedSeriesTotals||[];if(!n.length)return;let r=t.formatter||e.config.dataLabels.formatter,i=n.map((t,n)=>String(r?r(t,c(s({},e),{seriesIndex:0,dataPointIndex:n,w:e})):t)),a=new Graphics(e).getTextRects(_.getLargestStringFromArr(i),parseFloat(t.style.fontSize).toString(),t.style.fontFamily).width+Math.abs(t.offsetX||0)+2;this.dCtx.xPadRight=Math.max(this.dCtx.xPadRight,a)}gridPadFortitleSubtitle(){let{w:e}=this,{globals:t}=e,n=this.dCtx.isSparkline||!t.axisCharts?0:10;[`title`,`subtitle`].forEach(r=>{e.config[r].text===void 0?n+=this.dCtx.isSparkline||!t.axisCharts?0:5:n+=e.config[r].margin}),e.config.legend.show&&e.config.legend.position===`bottom`&&!e.config.legend.floating&&!t.axisCharts&&(n+=10);let r=this.dCtx.dimHelpers.getTitleSubtitleCoords(`title`),i=this.dCtx.dimHelpers.getTitleSubtitleCoords(`subtitle`);this.dCtx.titleBlockPad=n,e.layout.gridHeight-=r.height+i.height+n,e.layout.translateY+=r.height+i.height+n}setGridXPosForDualYAxis(e,t){let{w:n}=this,r=new AxesUtils(this.w,{theme:this.dCtx.theme,timeScale:this.dCtx.timeScale});n.config.yaxis.forEach((i,a)=>{n.globals.ignoreYAxisIndexes.indexOf(a)===-1&&!i.floating&&!r.isYAxisHidden(a)&&(i.opposite&&(n.layout.translateX-=t[a].width+e[a].width+parseInt(i.labels.style.fontSize,10)/1.2+12),n.layout.translateX<2&&(n.layout.translateX=2))})}}const kt=18,At=23;function jt(e,t){return s(s({show:!0,position:`top-left`,separator:` / `,rootLabel:`All`,offsetX:0,offsetY:0,formatter:void 0},e.config.drilldown&&e.config.drilldown.breadcrumb||{}),t||{})}class Dimensions{constructor(e,t){this.w=e,this.ctx=t,this.theme=t.theme,this.timeScale=t.timeScale,this.lgRect={},this.yAxisWidth=0,this.yAxisWidthLeft=0,this.yAxisWidthRight=0,this.xAxisHeight=0,this.isSparkline=this.w.config.chart.sparkline.enabled,this.dimHelpers=new Helpers(this),this.dimYAxis=new DimYAxis(this),this.dimXAxis=new DimXAxis(this),this.dimGrid=new DimGrid(this),this.lgWidthForSideLegends=0,this.gridPad=s({},this.w.config.grid.padding),this.xPadRight=0,this.titleBlockPad=0,this.xPadLeft=0,this.datalabelsCoords={width:0,height:0},this.xAxisWidth=0,this.timescaleLabels=[]}plotCoords(){let e=this.w,t=e.globals;if(this.gridPad=s({},e.config.grid.padding),this.lgRect=this.dimHelpers.getLegendsRect(),this.datalabelsCoords={width:0,height:0},this.isSparkline){this.w.globals.markers.largestSize>0&&Object.entries(this.gridPad).forEach(([e,t])=>{this.gridPad[e]=Math.max(t,this.w.globals.markers.largestSize/1.5)});let e=this.dimHelpers.getSparklineStrokeInset();this.gridPad.top=Math.max(e.top,this.gridPad.top),this.gridPad.bottom=Math.max(e.bottom,this.gridPad.bottom)}if(t.axisCharts?this.setDimensionsForAxisCharts():this.setDimensionsForNonAxisCharts(),this.dimGrid.gridPadFortitleSubtitle(),this.gridPadForBreadcrumb(),this.dimGrid.gridPadForStackedTotalDataLabels(),e.config.chart.type===`heatmap`&&e.config.plotOptions.heatmap.shape===`hexagon`&&!((e.config.xaxis.type===`numeric`||e.config.xaxis.type===`datetime`)&&e.axisFlags.isXNumeric)){let n=t.dataPoints||1,r=(e.seriesData.series||[]).length||1,i=e.layout.gridWidth-this.xPadRight-this.xPadLeft,a=e.layout.gridHeight,o=e.config.stroke.show?Array.isArray(e.config.stroke.width)?Math.max(...e.config.stroke.width):e.config.stroke.width:0,s=o/2+6,c=o/2,u=(i+4*n*s)/(4*n+2),d=(a+6*r*c)/(6*r+2);this.gridPad.left=Math.max(u,this.gridPad.left),this.gridPad.right=Math.max(u,this.gridPad.right),this.gridPad.top=Math.max(d,this.gridPad.top),this.gridPad.bottom=Math.max(d,this.gridPad.bottom)}e.layout.gridHeight=e.layout.gridHeight-this.gridPad.top-this.gridPad.bottom,e.layout.gridWidth=e.layout.gridWidth-this.gridPad.left-this.gridPad.right-this.xPadRight-this.xPadLeft;let n=this.dimGrid.gridPadForColumnsInNumericAxis(e.layout.gridWidth);return e.layout.gridWidth=e.layout.gridWidth-n*2,e.layout.translateX=e.layout.translateX+this.gridPad.left+this.xPadLeft+(n>0?n:0),e.layout.translateY=e.layout.translateY+this.gridPad.top,{layout:{gridHeight:e.layout.gridHeight,gridWidth:e.layout.gridWidth,translateX:e.layout.translateX,translateY:e.layout.translateY,translateXAxisX:e.layout.translateXAxisX,translateXAxisY:e.layout.translateXAxisY,rotateXLabels:e.layout.rotateXLabels,xAxisHeight:e.layout.xAxisHeight,xAxisLabelsHeight:e.layout.xAxisLabelsHeight,xAxisGroupLabelsHeight:e.layout.xAxisGroupLabelsHeight,xAxisLabelsWidth:e.layout.xAxisLabelsWidth,yLabelsCoords:e.layout.yLabelsCoords,yTitleCoords:e.layout.yTitleCoords,gridPad:s({},this.gridPad)}}}gridPadForBreadcrumb(){var e,t,n,r,i,a;let o=this.w,s=o.config.chart.type===`treemap`;if(s){let n=(t=(e=o.config.plotOptions)==null?void 0:e.treemap)==null?void 0:t.zoom;if(n&&n.enabled){if(jt(o,n.breadcrumb).show===!1)return;this.gridPad.top+=22;return}}if(!o.globals.axisCharts||!this.ctx.drilldown||!o.config.drilldown||!o.config.drilldown.enabled||jt(o).show===!1)return;let c=parseFloat(String((a=(i=(r=(n=o.config.yaxis)==null?void 0:n[0])==null?void 0:r.labels)==null?void 0:i.style)==null?void 0:a.fontSize))||11,u=24+(s?0:Math.ceil(c*j/2)),d=s?0:this.titleBlockPad||0;this.gridPad.top+=Math.max(0,u-d)}setDimensionsForAxisCharts(){let e=this.w,t=e.globals,n=this.dimYAxis.getyAxisLabelsCoords(),r=this.dimYAxis.getyAxisTitleCoords();t.isSlopeChart&&(this.datalabelsCoords=this.dimHelpers.getDatalabelsRect()),e.layout.yLabelsCoords=[],e.layout.yTitleCoords=[],e.config.yaxis.map((t,i)=>{e.layout.yLabelsCoords.push({width:n[i].width,index:i}),e.layout.yTitleCoords.push({width:r[i].width,index:i})}),this.yAxisWidth=this.dimYAxis.getTotalYAxisWidth();let i=this.dimXAxis.getxAxisLabelsCoords(),a=this.dimXAxis.getxAxisGroupLabelsCoords(),o=this.dimXAxis.getxAxisTitleCoords();this.conditionalChecksForAxisCoords(i,o,a),e.layout.translateXAxisY=e.layout.rotateXLabels?this.xAxisHeight/8:-4,e.layout.translateXAxisX=e.layout.rotateXLabels&&e.axisFlags.isXNumeric&&e.config.xaxis.labels.rotate<=-45?-this.xAxisWidth/4:0,e.globals.isBarHorizontal&&(e.layout.rotateXLabels=!1,e.layout.translateXAxisY=-1*((parseInt(e.config.xaxis.labels.style.fontSize,10)||12)/1.5)),e.layout.translateXAxisY=e.layout.translateXAxisY+e.config.xaxis.labels.offsetY,e.layout.translateXAxisX=e.layout.translateXAxisX+e.config.xaxis.labels.offsetX;let s=this.yAxisWidth,c=this.xAxisHeight;e.layout.xAxisLabelsHeight=this.xAxisHeight-o.height,e.layout.xAxisGroupLabelsHeight=e.layout.xAxisLabelsHeight-i.height,e.layout.xAxisLabelsWidth=this.xAxisWidth,e.layout.xAxisHeight=this.xAxisHeight;let u=10;(e.config.chart.type===`radar`||this.isSparkline)&&(s=0,c=0),this.isSparkline&&(this.lgRect={height:0,width:0}),(this.isSparkline||e.config.chart.type===`treemap`)&&(s=0,c=0,u=0),!this.isSparkline&&e.config.chart.type!==`treemap`&&this.dimXAxis.additionalPaddingXLabels(i);let d=()=>{e.layout.translateX=s+this.datalabelsCoords.width,e.layout.gridHeight=t.svgHeight-this.lgRect.height-c-(!this.isSparkline&&e.config.chart.type!==`treemap`?e.layout.rotateXLabels?10:15:0),e.layout.gridWidth=t.svgWidth-s-this.datalabelsCoords.width*2};switch(e.config.xaxis.position===`top`&&(u=e.layout.xAxisHeight-e.config.xaxis.axisTicks.height-5),e.config.legend.position){case`bottom`:e.layout.translateY=u,d();break;case`top`:e.layout.translateY=this.lgRect.height+u,d();break;case`left`:e.layout.translateY=u,e.layout.translateX=this.lgRect.width+s+this.datalabelsCoords.width,e.layout.gridHeight=t.svgHeight-c-12,e.layout.gridWidth=t.svgWidth-this.lgRect.width-s-this.datalabelsCoords.width*2;break;case`right`:e.layout.translateY=u,e.layout.translateX=s+this.datalabelsCoords.width,e.layout.gridHeight=t.svgHeight-c-12,e.layout.gridWidth=t.svgWidth-this.lgRect.width-s-this.datalabelsCoords.width*2-5;break;default:throw Error(`Legend position not supported`)}this.dimGrid.setGridXPosForDualYAxis(r,n),new YAxis(this.w,{theme:this.theme,timeScale:this.timeScale}).setYAxisXPosition(n,r)}setDimensionsForNonAxisCharts(){let e=this.w,t=e.globals,n=e.config,r=0;if(e.config.legend.show&&!e.config.legend.floating&&(r=20),n.chart.type===`unit`){let i=n.legend.show&&!n.legend.floating,a=n.legend.position,o=0,s=0;i&&(a===`bottom`||a===`top`?o=this.lgRect.height:s=this.lgRect.width+r),e.layout.gridWidth=t.svgWidth-s,e.layout.gridHeight=t.svgHeight-o,e.layout.translateX=a===`left`?s:0,e.layout.translateY=a===`top`?o:0;return}let i=n.chart.type===`sunburst`?`sunburst`:n.chart.type===`pie`||n.chart.type===`polarArea`||n.chart.type===`donut`?`pie`:`radialBar`,a=n.plotOptions[i].offsetY,o=n.plotOptions[i].offsetX;if(!n.legend.show||n.legend.floating){e.layout.gridHeight=t.svgHeight;let n=e.dom.elWrap.getBoundingClientRect().width;e.layout.gridWidth=Math.min(n,e.layout.gridHeight),e.layout.translateY=a,e.layout.translateX=o+(t.svgWidth-e.layout.gridWidth)/2;return}switch(n.legend.position){case`bottom`:e.layout.gridHeight=t.svgHeight-this.lgRect.height,e.layout.gridWidth=t.svgWidth,e.layout.translateY=a-10,e.layout.translateX=o+(t.svgWidth-e.layout.gridWidth)/2;break;case`top`:e.layout.gridHeight=t.svgHeight-this.lgRect.height,e.layout.gridWidth=t.svgWidth,e.layout.translateY=this.lgRect.height+a+10,e.layout.translateX=o+(t.svgWidth-e.layout.gridWidth)/2;break;case`left`:e.layout.gridWidth=t.svgWidth-this.lgRect.width-r,e.layout.gridHeight=n.chart.height===`auto`?e.layout.gridWidth:t.svgHeight,e.layout.translateY=a,e.layout.translateX=o+this.lgRect.width+r;break;case`right`:e.layout.gridWidth=t.svgWidth-this.lgRect.width-r-5,e.layout.gridHeight=n.chart.height===`auto`?e.layout.gridWidth:t.svgHeight,e.layout.translateY=a,e.layout.translateX=o+10;break;default:throw Error(`Legend position not supported`)}}conditionalChecksForAxisCoords(e,t,n){let r=this.w,i=r.labelData.hasXaxisGroups?2:1,a=n.height+e.height+t.height,o=r.axisFlags.isMultiLineX?1.2:j,s=r.layout.rotateXLabels?22:10,c=r.layout.rotateXLabels&&r.config.legend.position===`bottom`?10:0;this.xAxisHeight=a*o+i*s+c,this.xAxisWidth=e.width,this.xAxisHeight-t.height>r.config.xaxis.labels.maxHeight&&(this.xAxisHeight=r.config.xaxis.labels.maxHeight),r.config.xaxis.labels.minHeight&&this.xAxisHeight<r.config.xaxis.labels.minHeight&&(this.xAxisHeight=r.config.xaxis.labels.minHeight),r.config.xaxis.floating&&(this.xAxisHeight=0);let u=0,d=0;r.config.yaxis.forEach(e=>{u+=e.labels.minWidth,d+=e.labels.maxWidth}),this.yAxisWidth<u&&(this.yAxisWidth=u),this.yAxisWidth>d&&(this.yAxisWidth=d)}}const q=1e3,Mt=60*q,Nt=60*Mt,J=24*Nt,Pt=7*J,Ft=30*J,Y=365*J,It=10/(1440*60),Lt=[{unit:`second`,step:1,approxMs:q},{unit:`second`,step:5,approxMs:5*q},{unit:`second`,step:15,approxMs:15*q},{unit:`second`,step:30,approxMs:30*q},{unit:`minute`,step:1,approxMs:Mt},{unit:`minute`,step:5,approxMs:5*Mt},{unit:`minute`,step:15,approxMs:15*Mt},{unit:`minute`,step:30,approxMs:30*Mt},{unit:`hour`,step:1,approxMs:Nt},{unit:`hour`,step:3,approxMs:3*Nt},{unit:`hour`,step:6,approxMs:6*Nt},{unit:`hour`,step:12,approxMs:12*Nt},{unit:`day`,step:1,approxMs:J},{unit:`day`,step:2,approxMs:2*J},{unit:`week`,step:1,approxMs:Pt},{unit:`week`,step:2,approxMs:2*Pt},{unit:`month`,step:1,approxMs:Ft},{unit:`month`,step:3,approxMs:3*Ft},{unit:`month`,step:6,approxMs:6*Ft},{unit:`year`,step:1,approxMs:Y},{unit:`year`,step:2,approxMs:2*Y},{unit:`year`,step:5,approxMs:5*Y},{unit:`year`,step:10,approxMs:10*Y},{unit:`year`,step:25,approxMs:25*Y},{unit:`year`,step:50,approxMs:50*Y},{unit:`year`,step:100,approxMs:100*Y}],Rt=10;class TimeScale{constructor(e,t){this.w=e,this.ctx=t,this.tickInterval=null,this.timeScaleArray=[],this.utc=e.config.xaxis.labels.datetimeUTC}calculateTimeScaleTicks(e,t){let n=this.w;if(n.globals.allSeriesCollapsed)return n.labelData.labels=[],n.labelData.timescaleLabels=[],this.timeScaleArray=[],[];let r=t-e,i=r/J;n.interact.disableZoomIn=!1,n.interact.disableZoomOut=!1,i<.00011574074074074075?n.interact.disableZoomIn=!0:i>5e4&&(n.interact.disableZoomOut=!0);let a=Number.isFinite(n.config.xaxis.tickAmount)?n.config.xaxis.tickAmount:10;this.tickInterval=zt(r,a);let o=this.generateBaseTicks(e,t,this.tickInterval);return this.timeScaleArray=o,o}generateBaseTicks(e,t,n){let r=this.w,i=new DateTime(r),a=this.utc,o=r.layout.gridWidth,s=t-e,c=[],u=i.ceilToBoundary(e,n.unit,n.step,a),d=0,f=5e3;for(;u<=t&&d<5e3;){let t=i.getDateFields(u,a),r=s>0?(u-e)/s*o:0;c.push({timestamp:u,position:r,unit:n.unit,year:t.year,month:t.month+1,day:t.date,hour:t.hour,minute:t.minute,second:t.second,value:u}),u=i.addInterval(u,n.unit,n.step,a),d++}return c}recalcDimensionsBasedOnFormat(e){let t=this.w,n=this.formatDates(e),r=this.removeOverlappingTS(n);t.labelData.timescaleLabels=r.slice();let i=new Dimensions(this.w,this.ctx).plotCoords();this.ctx._writeLayoutCoords(i.layout)}formatDates(e){let t=this.w,n=new DateTime(t),r=t.config.xaxis.labels.format,i=t.config.xaxis.labels.datetimeFormatter,a=this.utc,o=(e,t=2)=>String(e).padStart(t,`0`),s=r||this._effectiveFormat(e,i);return e.map(e=>{let t=n.getDate(e.timestamp),r=n.formatDate(t,s);return{dateString:`${e.year}-${o(e.month)}-${o(e.day)}T${o(e.hour)}:${o(e.minute)}:${o(e.second)}.000${a?`Z`:``}`,position:e.position,value:r,unit:e.unit,year:e.year,month:e.month}})}_effectiveFormat(e,t){if(e.length===0)return t.day||`dd MMM`;let n=this.tickInterval&&this.tickInterval.unit||e[0].unit,r=t[n===`week`?`day`:n]||t.day||`dd MMM`,i=e[0],a=e[e.length-1],o=i.year!==a.year,s=o||i.month!==a.month||i.day!==a.day,c=/y/i.test(r),u=/M/.test(r),d=/d/i.test(r);return n===`month`||n===`week`||n===`day`?o&&!c?r+` yyyy`:r:(n===`hour`||n===`minute`||n===`second`)&&s&&!d&&!u?(o?`dd MMM yyyy`:`dd MMM`)+` `+r:r}removeOverlappingTS(e){if(e.length===0)return[];let t=this.w,n=new Graphics(t),r=!1,i;e[0].value&&e.every(t=>t.value.length===e[0].value.length)&&(r=!0,i=n.getTextRects(e[0].value,t.config.xaxis.labels.style.fontSize).width);let a=0;return e.map((o,s)=>{if(s===0||!t.config.xaxis.labels.hideOverlappingLabels)return o;let c=r?i:n.getTextRects(e[a].value,t.config.xaxis.labels.style.fontSize).width,u=e[a].position;return o.position>u+c+10?(a=s,o):null}).filter(e=>e!==null)}}function zt(e,t){if((!Number.isFinite(t)||t<=0)&&(t=10),e<=0)return Lt[0];let n=e/t,r=Lt[0],i=1/0;for(let e of Lt){let t=Math.abs(Math.log(e.approxMs/n));t<i&&(i=t,r=e)}return r}const Bt=`__apexcharts_registry__`,Vt=`__apexcharts_custom_types__`;globalThis[Bt]||(globalThis[Bt]={}),globalThis[Vt]||(globalThis[Vt]=/* @__PURE__ */ new Set);function Ht(){return globalThis[Bt]}function Ut(){return globalThis[Vt]}function Wt(e){Ut().add(e)}function X(e){return Ut().has(e)}function Gt(e){return!!Ht()[e]}function Kt(e){delete Ht()[e],Ut().delete(e)}function qt(e){Object.assign(Ht(),e)}function Z(e){let t=Ht()[e];if(!t)throw Error(`ApexCharts: chart type "${e}" is not registered. Bundler: import 'apexcharts/${e}'. Script tag: add <script src=".../dist/${e}.js"> after apexcharts.core.js, or load the full apexcharts.js instead.`);return t}class Core{constructor(e,t,n){this.w=t,this.ctx=n,this.el=e}setupElements(){let{globals:e,config:t}=this.w,n=t.chart.type,r=[`line`,`area`,`bar`,`rangeBar`,`rangeArea`,`candlestick`,`boxPlot`,`violin`,`scatter`,`bubble`],i=[...r,`radar`,`heatmap`,`treemap`],a=!i.includes(n)&&![`pie`,`donut`,`polarArea`,`radialBar`].includes(n)&&X(n);e.axisCharts=i.includes(n)||a,e.xyCharts=r.includes(n)||a,e.isBarHorizontal=[`bar`,`rangeBar`,`boxPlot`,`violin`].includes(n)&&t.plotOptions.bar.horizontal,e.chartClass=`.apexcharts${e.chartID}`,this.w.dom.baseEl=this.el,this.w.dom.elWrap=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`),Graphics.setAttrs(this.w.dom.elWrap,{id:e.chartClass.substring(1),class:`apexcharts-canvas ${e.chartClass.substring(1)}`}),this.el.appendChild(this.w.dom.elWrap);let o=globalThis.SVG;if(this.w.dom.Paper=o().addTo(this.w.dom.elWrap),this.w.dom.Paper.attr({class:`apexcharts-svg`,"xmlns:data":`ApexChartsNS`,transform:`translate(${t.chart.offsetX}, ${t.chart.offsetY})`}),this.w.dom.Paper.node.style.background=t.theme.mode===`dark`&&!t.chart.background?`#343A3F`:t.theme.mode===`light`&&!t.chart.background?`#fff`:t.chart.background,this.setSVGDimensions(),this.w.dom.elLegendForeign=BrowserAPIs.createElementNS(P,`foreignObject`),Graphics.setAttrs(this.w.dom.elLegendForeign,{x:0,y:0,width:e.svgWidth,height:e.svgHeight}),this.w.dom.elLegendWrap=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`),this.w.dom.elLegendWrap.classList.add(`apexcharts-legend`),this.w.dom.elWrap.appendChild(this.w.dom.elLegendWrap),this.w.dom.Paper.node.appendChild(this.w.dom.elLegendForeign),t.chart.accessibility.enabled&&t.chart.accessibility.announcements.enabled){let e=BrowserAPIs.createElement(`div`);e.className=`apexcharts-sr-status`,e.setAttribute(`role`,`status`),e.setAttribute(`aria-live`,`polite`),e.setAttribute(`aria-atomic`,`true`),this.w.dom.elWrap.appendChild(e)}if(t.chart.accessibility.enabled){let e=this.getAccessibleChartLabel(),n=t.chart.accessibility.keyboard.enabled&&t.chart.accessibility.keyboard.navigation.enabled?`application`:`img`;if(this.w.dom.Paper.attr({role:n,"aria-label":e}),t.chart.accessibility.description){let e=BrowserAPIs.createElementNS(P,`desc`);e.textContent=t.chart.accessibility.description,this.w.dom.Paper.node.insertBefore(e,this.w.dom.elLegendForeign.nextSibling)}}this.w.dom.elGraphical=this.w.dom.Paper.group().attr({class:`apexcharts-inner apexcharts-graphical`}),this.w.dom.elDefs=this.w.dom.Paper.defs(),this.w.dom.Paper.add(this.w.dom.elGraphical),this.w.dom.elGraphical.add(this.w.dom.elDefs)}_classifySeriesByType(e){let{w:t}=this,{config:n,globals:r}=t,i={line:{series:[],i:[]},area:{series:[],i:[]},scatter:{series:[],i:[]},bubble:{series:[],i:[]},bar:{series:[],i:[]},candlestick:{series:[],i:[]},boxPlot:{series:[],i:[]},violin:{series:[],i:[]},rangeBar:{series:[],i:[]},rangeArea:{series:[],seriesRangeEnd:[],i:[]}},a={},o=n.chart.type||`line`,s=null,c=0;return this.w.seriesData.series.forEach((n,r)=>{var u,d;let f=((u=e[r])==null?void 0:u.type)===`column`?`bar`:((d=e[r])==null?void 0:d.type)||(o===`column`?`bar`:o),p=i;p[f]?(f===`rangeArea`?(p[f].series.push(this.w.rangeData.seriesRangeStart[r]),p[f].seriesRangeEnd.push(this.w.rangeData.seriesRangeEnd[r])):p[f].series.push(n),p[f].i.push(r),f===`bar`&&(t.globals.columnSeries=i.bar)):[`heatmap`,`treemap`,`pie`,`donut`,`polarArea`,`radialBar`,`radar`,`unit`,`sunburst`].includes(f)?s=f:X(f)?(a[f]||(a[f]={series:[],i:[]}),a[f].series.push(n),a[f].i.push(r)):console.warn(`You have specified an unrecognized series type (${f}).`),o!==f&&f!==`scatter`&&c++}),c>0&&(s&&console.warn(`Chart or series type ${s} cannot appear with other chart or series types.`),i.bar.series.length>0&&n.plotOptions.bar.horizontal&&(c-=i.bar.series.length,i.bar={series:[],i:[]},t.globals.columnSeries={series:[],i:[]},console.warn("Horizontal bars are not supported in a mixed/combo chart. Please turn off `plotOptions.bar.horizontal`"))),r.comboCharts||(r.comboCharts=c>0),{seriesTypes:i,customBuckets:a}}plotChartType(e,t){let{w:n,ctx:r}=this,i=r.renderer&&r.renderer.kind===`canvas`;i&&r.renderer.beginSeries();let{seriesTypes:a,customBuckets:o}=this._classifySeriesByType(e),s=this._instantiateSeriesRenderers(a,t),c=this._assembleSeriesGraphics(a,o,s,t);if(i){let e=r.renderer;if(e&&e._repaintHostInPlace){e._repaintHostInPlace=!1;let t=this.w.dom.elGraphical.node.querySelector(`.apexcharts-canvas-series-wrap`);if(t&&e.canRepaintInPlace&&e.canRepaintInPlace())return e.repaintInPlace(),(Array.isArray(c)?c:[c]).forEach(e=>{e&&e.node&&t.appendChild(e.node)}),[]}let t=r.renderer.present();if(t){let e=new Graphics(n).group({class:`apexcharts-canvas-series-wrap`});return e.add(t),(Array.isArray(c)?c:[c]).forEach(t=>{t&&e.add(t)}),e}}return c}_instantiateSeriesRenderers(e,t){let{w:n,ctx:r}=this,{config:i,globals:a}=n,o=e.line.series.length>0||e.area.series.length>0||e.scatter.series.length>0||e.bubble.series.length>0||e.rangeArea.series.length>0||!a.comboCharts&&[`line`,`area`,`scatter`,`bubble`,`rangeArea`].includes(i.chart.type)?new(Z(`line`))(r.w,r,t):null,s=e.candlestick.series.length>0||e.boxPlot.series.length>0||!a.comboCharts&&[`candlestick`,`boxPlot`].includes(i.chart.type)?new(Z(`candlestick`))(r.w,r,t):null,c=e.violin.series.length>0||!a.comboCharts&&i.chart.type===`violin`?new(Z(`violin`))(r.w,r,t):null;return r.pie=!a.comboCharts&&[`pie`,`donut`,`polarArea`].includes(i.chart.type)?new(Z(`pie`))(r.w,r):null,r.rangeBar=e.rangeBar.series.length>0||!a.comboCharts&&i.chart.type===`rangeBar`?new(Z(`rangeBar`))(r.w,r,t):null,{line:o,boxCandlestick:s,violin:c}}_assembleSeriesGraphics(e,t,n,r){let{w:i,ctx:a}=this,{config:o,globals:s}=i,{line:c,boxCandlestick:u,violin:d}=n,f=[];if(s.comboCharts){let n=new CoreUtils(this.w);if(e.area.series.length>0&&f.push(...n.drawSeriesByGroup(e.area,s.areaGroups,`area`,c)),e.bar.series.length>0)if(o.chart.stacked){let t=new(Z(`barStacked`))(a.w,a,r);f.push(t.draw(e.bar.series,e.bar.i))}else a.bar=new(Z(`bar`))(a.w,a,r),f.push(a.bar.draw(e.bar.series,e.bar.i));if(e.rangeArea.series.length>0&&f.push(c.draw(e.rangeArea.series,`rangeArea`,e.rangeArea.i,e.rangeArea.seriesRangeEnd)),e.line.series.length>0&&f.push(...n.drawSeriesByGroup(e.line,s.lineGroups,`line`,c)),e.candlestick.series.length>0&&f.push(u.draw(e.candlestick.series,`candlestick`,e.candlestick.i)),e.boxPlot.series.length>0&&f.push(u.draw(e.boxPlot.series,`boxPlot`,e.boxPlot.i)),e.violin.series.length>0&&f.push(d.draw(e.violin.series,`violin`,e.violin.i)),e.rangeBar.series.length>0&&f.push(a.rangeBar.draw(e.rangeBar.series,e.rangeBar.i)),e.scatter.series.length>0){let t=new(Z(`line`))(a.w,a,r,!0);f.push(t.draw(e.scatter.series,`scatter`,e.scatter.i))}if(e.bubble.series.length>0){let t=new(Z(`line`))(a.w,a,r,!0);f.push(t.draw(e.bubble.series,`bubble`,e.bubble.i))}Object.keys(t).forEach(e=>{let n=t[e];if(n.series.length>0){let t=new(Z(e))(a.w,a,r);f.push(t.draw(n.series,e,n.i))}})}else{let e=o.chart.type;switch(e){case`line`:f=c.draw(this.w.seriesData.series,`line`);break;case`area`:f=c.draw(this.w.seriesData.series,`area`);break;case`bar`:o.chart.stacked?f=new(Z(`barStacked`))(a.w,a,r).draw(this.w.seriesData.series):(a.bar=new(Z(`bar`))(a.w,a,r),f=a.bar.draw(this.w.seriesData.series));break;case`candlestick`:f=u.draw(this.w.seriesData.series,`candlestick`);break;case`boxPlot`:f=u.draw(this.w.seriesData.series,e);break;case`violin`:f=d.draw(this.w.seriesData.series,`violin`);break;case`rangeBar`:f=a.rangeBar.draw(this.w.seriesData.series);break;case`rangeArea`:f=c.draw(this.w.rangeData.seriesRangeStart,`rangeArea`,void 0,this.w.rangeData.seriesRangeEnd);break;case`heatmap`:f=new(Z(`heatmap`))(a.w,a,r).draw(this.w.seriesData.series);break;case`treemap`:f=new(Z(`treemap`))(a.w,a).draw(this.w.seriesData.series);break;case`unit`:f=new(Z(`unit`))(a.w,a).draw(this.w.seriesData.series);break;case`sunburst`:f=new(Z(`sunburst`))(a.w,a).draw(this.w.seriesData.series);break;case`pie`:case`donut`:case`polarArea`:f=a.pie.draw(this.w.seriesData.series);break;case`radialBar`:f=new(Z(`radialBar`))(a.w,a).draw(this.w.seriesData.series);break;case`radar`:f=new(Z(`radar`))(a.w,a).draw(this.w.seriesData.series);break;default:f=X(e)?new(Z(e))(a.w,a,r).draw(this.w.seriesData.series,e):c.draw(this.w.seriesData.series)}}return f}_extractDimensionUnit(e){return String(e).split(/[0-9]+/g).pop()}setSVGDimensions(){var e;let{globals:t,config:n}=this.w;n.chart.width=n.chart.width||`100%`,n.chart.height=n.chart.height||`auto`;let r=n.chart.width,i=n.chart.height;t.svgWidth=NaN,t.svgHeight=NaN;let a=_.getDimensions(this.el),o=this._extractDimensionUnit(r);o===`%`?_.isNumber(a[0])&&(a[0].width===0&&(a=_.getDimensions(this.el.parentNode)),t.svgWidth=a[0]*parseInt(r,10)/100):(o===`px`||o===``)&&(t.svgWidth=parseInt(r,10));let s=this._extractDimensionUnit(i);if(i!==`auto`&&i!==``?s===`%`?t.svgHeight=_.getDimensions(this.el.parentNode)[1]*parseInt(i,10)/100:t.svgHeight=parseInt(i,10):t.svgHeight=t.axisCharts?t.svgWidth/1.61:t.svgWidth/1.2,this._applyWeaveReservation(t),t.svgWidth=Math.max(t.svgWidth,0),t.svgHeight=Math.max(t.svgHeight,0),Graphics.setAttrs(this.w.dom.Paper.node,{width:t.svgWidth,height:t.svgHeight}),s!==`%`&&Environment.isBrowser()){let r=t.axisCharts&&(n.grid.show||n.dataLabels.enabled||n.xaxis.labels.show||n.xaxis.axisBorder.show||n.xaxis.axisTicks.show||n.yaxis.some(e=>e.show&&(e.labels.show||e.axisBorder.show||e.axisTicks.show))),i=n.chart.sparkline.enabled||!r?0:n.chart.parentHeightOffset,a=this.w.dom.Paper.node;(e=a.parentNode)!=null&&e.parentNode&&(a.parentNode.parentNode.style.minHeight=`${t.svgHeight+i}px`)}this.w.dom.elWrap.style.width=`${t.svgWidth}px`,this.w.dom.elWrap.style.height=`${t.svgHeight}px`,t.lastResizeSignature=this.getResizeSignature()}_applyWeaveReservation(e){let t=this.ctx&&this.ctx.weave;if(!t||typeof t.reservedBox!=`function`)return;let n=t.reservedBox(),r=n.left+n.right,i=n.top+n.bottom;!r&&!i||(r&&Number.isFinite(e.svgWidth)&&(e.svgWidth-=Math.min(r,e.svgWidth/2)),i&&Number.isFinite(e.svgHeight)&&(e.svgHeight-=Math.min(i,e.svgHeight/2)))}getResizeSignature(){let{config:e}=this.w,t=(e.chart.width||`100%`).toString().trim(),n=(e.chart.height||`auto`).toString().trim(),r=0,i=0;if(t.endsWith(`%`)){let e=_.getDimensions(this.el);e[0]||(e=_.getDimensions(this.el.parentNode)),r=e[0]||0}n.endsWith(`%`)&&(i=_.getDimensions(this.el.parentNode)[1]||0);let a={w:Math.round(r),h:Math.round(i)};return e.responsive&&e.responsive.length&&Environment.isBrowser()&&(a.iw=window.innerWidth),a}shiftGraphPosition(){let{globals:e}=this.w,{translateY:t,translateX:n}=e;Graphics.setAttrs(this.w.dom.elGraphical.node,{transform:`translate(${n}, ${t})`})}resizeNonAxisCharts(){var e,t,n,r,i,a,o,s,c;let{w:u}=this,d=u.config.chart.height?String(u.config.chart.height):``,f=d!==``&&d!==`auto`,p=d.includes(`%`),m=0,h=u.config.chart.sparkline.enabled?1:15;h+=u.layout.gridPad.bottom,[`top`,`bottom`].includes(u.config.legend.position)&&u.config.legend.show&&!u.config.legend.floating&&(m=((t=(e=this.ctx.legend)==null?void 0:e.legendHelpers.getLegendDimensions().clwh)==null?0:t)+7);let g=u.dom.baseEl.querySelector(`.apexcharts-radialbar, .apexcharts-pie, .apexcharts-sunburst`),v=u.globals.pieExternalLabelMarginY||0,y=v>0?u.globals.radialSize*2+v*2:u.globals.radialSize*2.05,b=u.config.chart.type===`sunburst`?`sunburst`:u.config.chart.type===`pie`||u.config.chart.type===`donut`||u.config.chart.type===`polarArea`?`pie`:`radialBar`,x=Math.abs(u.config.plotOptions[b].endAngle-u.config.plotOptions[b].startAngle);if(g&&!u.config.chart.sparkline.enabled&&x<360){let e=_.getBoundingClientRect(this.w.dom.Paper.node),t=1/0,c=-1/0,d=n=>{var r,i,a,o;if((r=n.classList)!=null&&r.contains(`apexcharts-radialbar-hollow`))return;let s=(a=(i=n.tagName)==null?void 0:i.toLowerCase)==null?void 0:a.call(i);if(s===`text`||s===`tspan`)return;let u=Array.from((o=n.children)==null?[]:o);if(u.length>0){u.forEach(e=>d(e));return}let f=_.getBoundingClientRect(n);if(f.bottom-f.top>0){let n=f.top-e.top,r=f.bottom-e.top;n<t&&(t=n),r>c&&(c=r)}};Array.from((n=g.children)==null?[]:n).forEach(e=>d(e)),Number.isFinite(t)||(t=0),Number.isFinite(c)||(c=_.getBoundingClientRect(g).bottom-e.top);let f=Math.max(h,u.globals.radialSize*.2),v=Math.max(f-t,0);v!==0&&(u.layout.translateY=((r=u.layout.translateY)==null?0:r)+v,Graphics.setAttrs(this.w.dom.elGraphical.node,{transform:`translate(${(i=u.layout.translateX)==null?0:i}, ${u.layout.translateY})`}),c+=v),y=c>0?c:u.globals.radialSize*2.05;let b=Math.max(f,t),x=Math.ceil(y+m+b),S=(a=u.config.chart.offsetY)==null?0:a,C=x+Math.max(S,0);if(!p){if(this.w.dom.elLegendForeign&&this.w.dom.elLegendForeign.setAttribute(`height`,String(C)),this.w.dom.elWrap.style.height=`${C}px`,Graphics.setAttrs(this.w.dom.Paper.node,{height:x}),Environment.isBrowser()){let e=(o=this.w.dom.Paper.node.parentNode)==null?void 0:o.parentNode;e&&(e.style.minHeight=`${C}px`)}u.globals.svgHeight=x,u.config.legend.position===`bottom`&&u.config.legend.show&&!u.config.legend.floating&&((s=this.ctx.legend)==null||s.setLegendWrapXY(20,0))}return}let S=Math.ceil(y+this.w.layout.translateY+m+h);if(!f&&(this.w.dom.elLegendForeign&&this.w.dom.elLegendForeign.setAttribute(`height`,String(S)),this.w.dom.elWrap.style.height=`${S}px`,Graphics.setAttrs(this.w.dom.Paper.node,{height:S}),Environment.isBrowser())){let e=(c=this.w.dom.Paper.node.parentNode)==null?void 0:c.parentNode;e&&(e.style.minHeight=`${S}px`)}}coreCalculations(){new Range(this.w).init()}resetGlobals(){let e=()=>this.w.config.series.map(()=>[]),t=new Globals,{globals:n}=this.w,r={dataWasParsed:this.w.axisFlags.dataWasParsed,originalSeries:n.originalSeries};t.initGlobalVars(n),n.seriesXvalues=e(),n.seriesYvalues=e(),r.dataWasParsed&&(this.w.axisFlags.dataWasParsed=r.dataWasParsed,n.originalSeries=r.originalSeries)}isMultipleY(){return Array.isArray(this.w.config.yaxis)&&this.w.config.yaxis.length>1?(this.w.globals.isMultipleYAxis=!0,!0):!1}xySettings(){let{w:e}=this,t=null;if(e.globals.axisCharts){if(e.config.xaxis.crosshairs.position===`back`&&new Crosshairs(this.w).drawXCrosshairs(),e.config.yaxis[0].crosshairs.position===`back`&&new Crosshairs(this.w).drawYCrosshairs(),e.config.xaxis.type===`datetime`&&e.config.xaxis.labels.formatter===void 0){this.ctx.timeScale=new TimeScale(this.w,this.ctx);let t=[];isFinite(e.globals.minX)&&isFinite(e.globals.maxX)&&!e.globals.isBarHorizontal?t=this.ctx.timeScale.calculateTimeScaleTicks(e.globals.minX,e.globals.maxX):e.globals.isBarHorizontal&&(t=this.ctx.timeScale.calculateTimeScaleTicks(e.globals.minY,e.globals.maxY)),this.ctx.timeScale.recalcDimensionsBasedOnFormat(t)}t=new CoreUtils(this.w).getCalculatedRatios()}return t}updateSourceChart(e){this.ctx.w.interact.selection=void 0,this.ctx.updateHelpers._updateOptions({chart:{selection:{xaxis:{min:e.w.globals.minX,max:e.w.globals.maxX}}}},!1,!1)}setupBrushHandler(){let{ctx:e,w:t}=this;if(t.config.chart.brush.enabled&&typeof t.config.chart.events.selection!=`function`){let n=Array.isArray(t.config.chart.brush.targets)?t.config.chart.brush.targets:[t.config.chart.brush.target];n.forEach(t=>{let n=e.constructor.getChartByID(t);if(!n){console.warn(`ApexCharts: brush target "${t}" was not found. Ensure the target chart is rendered (and its chart.id matches) before the brush chart.`);return}n.w.globals.brushSource=this.ctx,typeof n.w.config.chart.events.zoomed!=`function`&&(n.w.config.chart.events.zoomed=()=>this.updateSourceChart(n)),typeof n.w.config.chart.events.scrolled!=`function`&&(n.w.config.chart.events.scrolled=()=>this.updateSourceChart(n))}),t.config.chart.events.selection=(t,r)=>{n.forEach(t=>{let n=e.constructor.getChartByID(t);n&&n.ctx.updateHelpers._updateOptions({xaxis:{min:r.xaxis.min,max:r.xaxis.max}},!1,!1,!1,!1)})}}}getAccessibleChartLabel(){let e=this.w,t=e.config;if(t.chart.accessibility&&t.chart.accessibility.description)return t.chart.accessibility.description;let n=t.chart.type,r=[];if(t.title.text)r.push(`${t.title.text}. ${n} chart`),t.subtitle.text&&r.push(t.subtitle.text);else{let i=Array.isArray(e.seriesData.seriesNames)&&e.seriesData.seriesNames.length?e.seriesData.seriesNames.filter(Boolean):Array.isArray(t.series)?t.series.map(e=>typeof e==`object`&&e?e.name:null).filter(Boolean):[],a=e.seriesData.series.length||(t.series?t.series.length:0);i.length?r.push(`${n} chart with ${a} data series: ${i.join(`, `)}`):r.push(`${n} chart with ${a} data series`)}return r.join(`. `)}}const Jt=`__apexcharts_series_transforms__`;globalThis[Jt]||(globalThis[Jt]={});function Yt(){return globalThis[Jt]}function Xt(e){return e&&Yt()[e]||null}function Zt(e,t){let n=e.config.drilldown;return(n&&Array.isArray(n.series)?n.series:[]).find(e=>e&&e.id===t)}function Qt(e,t,n,r,i,a=null,o={}){var s,c,u;let d=t&&typeof t==`object`,f=d?(c=(s=t.x)==null?t.name:s)==null?``:c:``,p=Number(d?(u=t.y)==null?t.value:u:t),m={name:String(f),value:isNaN(p)?null:p,color:d&&t.color?t.color:void 0,_key:`${i}/${n}:${f}`};if(r&&!m.color&&(m.color=r[n%r.length]),o.keepDatum&&(m._datum=t),d&&Array.isArray(t.children)&&t.children.length)m.children=t.children.map((t,n)=>Qt(e,t,n,null,m._key,a,o));else if(d&&t.drilldown!=null&&o.expandDrilldown!==!1){let n=a||/* @__PURE__ */ new Set;if(!n.has(t.drilldown)){let r=Zt(e,t.drilldown);if(r&&Array.isArray(r.data)&&r.data.length){let i=new Set(n);i.add(t.drilldown);let a=Array.isArray(r.colors)?r.colors:null;m.children=r.data.map((t,n)=>Qt(e,t,n,a,m._key,i,o))}}}return m}function $t(e,t,n={}){let r=t||e.config.series;return Array.isArray(r)?r.map((t,r)=>{var i,a;let o=t&&Array.isArray(t.data)?t.data:[],s=`${r}:${(i=t==null?void 0:t.name)==null?``:i}`;return{name:String((a=t==null?void 0:t.name)==null?``:a),value:null,color:(t==null?void 0:t.color)||void 0,_key:s,_seriesIndex:r,children:o.map((t,r)=>Qt(e,t,r,null,s,null,n))}}):[]}function en(e){e.children&&e.children.length&&(e.children.forEach(e=>en(e)),(e.value==null||isNaN(e.value))&&(e.value=e.children.reduce((e,t)=>e+Math.max(0,t.value||0),0))),(e.value==null||isNaN(e.value))&&(e.value=0)}function tn(e,t={}){if(!Array.isArray(e))return!1;let n=t.drilldown!==!1;for(let t=0;t<e.length;t++){let r=e[t]&&e[t].data;if(Array.isArray(r))for(let e=0;e<r.length;e++){let t=r[e];if(!(!t||typeof t!=`object`)&&(Array.isArray(t.children)&&t.children.length||n&&t.drilldown!=null))return!0}}return!1}function nn(e){var t,n,r,i;return!!((i=(r=(n=(t=e==null?void 0:e.config)==null?void 0:t.plotOptions)==null?void 0:n.treemap)==null?void 0:r.nested)!=null&&i.drilldownAsLevels)}function rn(e,t){var n,r,i;let a=(i=(r=(n=e==null?void 0:e.config)==null?void 0:n.plotOptions)==null?void 0:r.treemap)==null?void 0:i.nested;return a&&a.enabled===!1?!1:tn(t,{drilldown:nn(e)})}function an(e){let t=[],n=0;return e.forEach((e,r)=>{let i=[],a=(e,t,o)=>{e._parent=o,e._depth=t,e._si=r,e._leaf=!(e.children&&e.children.length),t>n&&(n=t),e._leaf?(e._di=i.length,i.push(e)):(e._di=-1,e.children.forEach(n=>a(n,t+1,e)))};a(e,0,null),t.push(i)}),{leaves:t,maxDepth:n}}function on(e){let t=e._datum;if(t&&typeof t==`object`){let n=c(s({},t),{x:e.name,y:e.value});return delete n.children,n}return{x:e.name,y:e.value}}function sn(e,t){let n=$t(e,t,{keepDatum:!0,expandDrilldown:nn(e)});n.forEach(en);let{leaves:r,maxDepth:i}=an(n);return{roots:n,leafSeries:t.map((e,t)=>c(s({},e),{data:(r[t]||[]).map(on)})),maxDepth:i}}const cn={histogram:`stats`,raincloud:`raincloud`};class Data{constructor(e,{resetGlobals:t=()=>{},isMultipleY:n=()=>{}}={}){this.w=e,this.resetGlobals=t,this.isMultipleY=n,this.twoDSeries=[],this.threeDSeries=[],this.twoDSeriesX=[],this.seriesGoals=[],this._warnedMissingTransform=!1,this.coreUtils=new CoreUtils(this.w),this.activeSeriesIndex=0}getFirstDataPoint(){let e=this.w.config.series,t=new Series(this.w);this.activeSeriesIndex=t.getActiveConfigSeriesIndex();let n=e[this.activeSeriesIndex];return n&&n.data&&n.data.length>0&&n.data[0]!==null&&n.data[0]!==void 0?n.data[0]:null}isMultiFormat(){return this.isFormatXY()||this.isFormat2DArray()}isFormatXY(){var e;let t=this.getFirstDataPoint();if(!t||t.x===void 0)return!1;let n=(e=this.w.config.series[this.activeSeriesIndex])==null?void 0:e.data;if(n){let e=e=>e&&e.x!==void 0;for(let t=1;t<Math.min(3,n.length);t++)if(e(n[t])!==!0){console.warn(`ApexCharts: series data has mixed formats starting at index ${t}`);break}}return!0}isFormat2DArray(){let e=this.getFirstDataPoint();return e&&Array.isArray(e)}_fast2DArrayParse(e,t){var n,r;let i=e.length;if(i===0)return!1;let a=Array(i),o=Array(i),s=-Number.MAX_VALUE,c=Number.MAX_VALUE,u=1/0,d=!1,f=0,p=!0,m=1/0,h=-1/0,g=!0,v=1/0,y=NaN;for(let t=0;t<i;t++){let n=e[t];if(!Array.isArray(n)||n.length>2)return!1;let r=n[0],i=n[1];if(p)if(typeof r==`number`){r===r&&(r<m&&(m=r),r>h&&(h=r));let e=r-y;e>0?e<v&&(v=e):e<0&&(g=!1),y=r}else p=!1;if(typeof i==`number`)if(i===i&&i!==1/0&&i!==-1/0){if(i>s&&(s=i),i<c&&(c=i),i<0&&i<u&&(u=i),!Number.isInteger(i)){let e=i<0?-i:i;if(e>=1e-6&&e<1e21){let e=``+i,t=e.indexOf(`.`),n=t===-1?0:e.length-t-1;n>f&&(f=n)}else{let e=_.noExponents(i);_.isFloat(e)&&(f=Math.max(f,e.toString().split(`.`)[1].length))}}}else d=!0;else if(i===null)d=!0;else return!1;a[t]=i,o[t]=r}this.twoDSeries=a,this.twoDSeriesX=o,this.w.axisFlags.dataFormatXNumeric=!0;let b=(r=(n=this.w.seriesData)._parsedExtrema)==null?n._parsedExtrema=[]:r;return b[t]={ref:a,len:i,maxY:s,lowestY:c,negMinY:u,hasNulls:d,yDec:f,xref:o,xNumeric:p,minX:m,maxX:h,xSorted:g,minXDiff:v},!0}handleFormat2DArray(e,t){let n=this.w.config,r=e[t].data,i=n.chart.type===`boxPlot`||n.series[t].type===`boxPlot`;if(!(!i&&n.xaxis.type!==`datetime`&&this._fast2DArrayParse(r,t)))for(let e=0;e<r.length;e++){let t=r[e],a=t[0],o=t[1],s=t[2];if(o!==void 0&&(Array.isArray(o)&&o.length===4&&!i?this.twoDSeries.push(_.parseNumber(o[3])):t.length>=5?this.twoDSeries.push(_.parseNumber(t[4])):this.twoDSeries.push(_.parseNumber(o)),this.w.axisFlags.dataFormatXNumeric=!0),n.xaxis.type===`datetime`){let e=new Date(a).getTime();this.twoDSeriesX.push(e)}else this.twoDSeriesX.push(a);s!==void 0&&(this.threeDSeries.push(s),this.w.axisFlags.isDataXYZ=!0)}}handleFormatXY(e,t){let n=this.w.config,r=this.w.globals,i=new DateTime(this.w),a=e[t].data,o=t;r.collapsedSeriesIndices.indexOf(t)>-1&&(o=this.activeSeriesIndex);let s=e[o].data;for(let e=0;e<a.length;e++){let n=a[e];if(n.y!==void 0){let e=Array.isArray(n.y)?_.parseNumber(n.y[n.y.length-1]):_.parseNumber(n.y);this.twoDSeries.push(e)}this.seriesGoals[t]===void 0&&(this.seriesGoals[t]=[]),n.goals!==void 0&&Array.isArray(n.goals)?this.seriesGoals[t].push(n.goals):this.seriesGoals[t].push(null),n.z!==void 0&&(this.threeDSeries.push(n.z),this.w.axisFlags.isDataXYZ=!0)}for(let e=0;e<s.length;e++){let t=s[e].x,a=typeof t==`string`,o=Array.isArray(t),c=!o&&!!i.isValidDate(t);if(a||c)if(a||n.xaxis.convertedCatToNumeric){let e=r.isBarHorizontal&&this.w.axisFlags.isRangeData;n.xaxis.type===`datetime`&&!e?this.twoDSeriesX.push(i.parseDate(t)):(this.fallbackToCategory=!0,this.twoDSeriesX.push(t),!isNaN(t)&&this.w.config.xaxis.type!==`category`&&typeof t!=`string`&&(this.w.axisFlags.isXNumeric=!0))}else n.xaxis.type===`datetime`?this.twoDSeriesX.push(t instanceof Date?t.getTime():i.parseDate(t.toString())):(this.w.axisFlags.dataFormatXNumeric=!0,this.w.axisFlags.isXNumeric=!0,this.twoDSeriesX.push(t instanceof Date?t.getTime():parseFloat(t)));else o?(this.fallbackToCategory=!0,this.twoDSeriesX.push(t)):(this.w.axisFlags.isXNumeric=!0,this.w.axisFlags.dataFormatXNumeric=!0,this.twoDSeriesX.push(t))}}handleRangeData(e,t){let n={start:[],end:[],rangeUniques:[]};return this.isFormat2DArray()?n=this.handleRangeDataFormat(`array`,e,t):this.isFormatXY()&&(n=this.handleRangeDataFormat(`xy`,e,t)),this.w.rangeData.seriesRangeStart[t]=n.start===void 0?[]:n.start,this.w.rangeData.seriesRangeEnd[t]=n.end===void 0?[]:n.end,this.w.rangeData.seriesRange[t]=n.rangeUniques,this.w.rangeData.seriesRange.forEach(e=>{e&&e.forEach(e=>{let t=e.y,n=t.length;if(!(n<=1))for(let r=0;r<n;r++){let i=t[r],a=i.y1,o=i.y2;for(let s=r+1;s<n;s++){let n=t[s],r=n.y1;if(a<=n.y2&&r<=o){let t=e;t.overlaps.add(i.rangeName),t.overlaps.add(n.rangeName)}}}})}),n}handleCustomRangeData(e,t,n){let r=e[t].data||[],i=[],a=[];for(let e=0;e<r.length;e++){let t=r[e],o,s;if(typeof n==`function`){let r=n(t,e);Array.isArray(r)||(r=[r]);let i=r.map(e=>_.parseNumber(e)).filter(e=>e!==null&&!isNaN(e));o=i.length?Math.min(...i):null,s=i.length?Math.max(...i):null}else{let e=t==null?null:t.y;Array.isArray(e)?(o=_.parseNumber(e[0]),s=_.parseNumber(e[e.length-1])):o=s=_.parseNumber(e)}i.push(o),a.push(s)}this.w.rangeData.seriesRangeStart[t]=i,this.w.rangeData.seriesRangeEnd[t]=a}handleCandleStickBoxData(e,t){let n={o:[],h:[],m:[],l:[],c:[]};return this.isFormat2DArray()?n=this.handleCandleStickBoxDataFormat(`array`,e,t):this.isFormatXY()&&(n=this.handleCandleStickBoxDataFormat(`xy`,e,t)),this.w.candleData.seriesCandleO[t]=n.o,this.w.candleData.seriesCandleH[t]=n.h,this.w.candleData.seriesCandleM[t]=n.m,this.w.candleData.seriesCandleL[t]=n.l,this.w.candleData.seriesCandleC[t]=n.c,this.w.candleData.seriesBoxPoints[t]=n.points||[],n}handleViolinData(e,t){var n,r,i,a,o,s,c,u;let d=this.w,f=e[t].data,p=[],m=[],h=[],g=[],v=[],y=[];for(let e=0;e<f.length;e++){let t=f[e],d=(i=(r=(n=t==null?void 0:t.y)==null?void 0:n.density)==null?t==null?void 0:t[1]:r)==null?[]:i,b=(s=(o=(a=t==null?void 0:t.y)==null?void 0:a.points)==null?t==null?void 0:t[2]:o)==null?[]:s,x=this._parseViolinSummary((u=(c=t==null?void 0:t.y)==null?void 0:c.summary)==null?t==null?void 0:t[3]:u),S=[],C=[],w=0,T=null,E=1/0,D=-1/0;for(let e=0;e<d.length;e++){let t=_.parseNumber(d[e][0]),n=_.parseNumber(d[e][1]);t===null||n===null||(S.push(t),C.push(n),n>w&&(w=n,T=t),t<E&&(E=t),t>D&&(D=t))}let O=[];for(let e=0;e<b.length;e++){let t=_.parseNumber(b[e]);t!==null&&(O.push(t),t<E&&(E=t),t>D&&(D=t))}x&&(x[0]<E&&(E=x[0]),x[4]>D&&(D=x[4])),p.push({values:S,weights:C,maxWeight:w}),m.push(O),h.push(x),g.push(E===1/0?0:E),v.push(D===-1/0?0:D),y.push(T===null?O.length?O[Math.floor(O.length/2)]:0:T)}d.violinData.seriesViolinDensity[t]=p,d.violinData.seriesViolinPoints[t]=m,d.violinData.seriesViolinSummary[t]=h,d.violinData.seriesViolinMin[t]=g,d.violinData.seriesViolinMax[t]=v,this.twoDSeries=y}_parseViolinSummary(e){if(!Array.isArray(e)||e.length!==5)return null;let t=[];for(let n=0;n<5;n++){let r=_.parseNumber(e[n]);if(r===null||n>0&&r<t[n-1])return null;t.push(r)}return t}handleRangeDataFormat(e,t,n){let r=[],i=[],a=/* @__PURE__ */ new Map,o=[];if(t[n].data.forEach(e=>{if(!a.has(e.x)){let t={x:e.x,overlaps:/* @__PURE__ */ new Set,y:[]};a.set(e.x,t),o.push(t)}}),e===`array`)for(let e=0;e<t[n].data.length;e++)Array.isArray(t[n].data[e])?(r.push(t[n].data[e][1][0]),i.push(t[n].data[e][1][1])):(r.push(t[n].data[e]),i.push(t[n].data[e]));else if(e===`xy`)for(let e=0;e<t[n].data.length;e++){let o=Array.isArray(t[n].data[e].y),s=_.randomId(),c=t[n].data[e].x,u={y1:o?t[n].data[e].y[0]:t[n].data[e].y,y2:o?t[n].data[e].y[1]:t[n].data[e].y,rangeName:s},d=this.w.globals;d.seriesRangeName||(d.seriesRangeName={}),d.seriesRangeName[n]||(d.seriesRangeName[n]={}),d.seriesRangeName[n][e]=s;let f=a.get(c);f&&f.y.push(u),r.push(u.y1),i.push(u.y2)}return{start:r,end:i,rangeUniques:o}}handleCandleStickBoxDataFormat(e,t,n){let r=this.w,i=r.config.chart.type===`boxPlot`||r.config.series[n].type===`boxPlot`,a=[],o=[],s=[],c=[],u=[],d=[],f=t[n].data,p;if(e===`array`){let e=f[0];p=i&&e&&e.length===6||!i&&e&&e.length===5?e=>e.slice(1):e=>Array.isArray(e[1])?e[1]:[]}else p=e=>Array.isArray(e.y)?e.y:[];for(let e=0;e<f.length;e++){let t=p(f[e]);t&&t.length>=2&&(a.push(t[0]),o.push(t[1]),i?(s.push(t[2]),c.push(t[3]),u.push(t[4])):(c.push(t[2]),u.push(t[3])));let n=f[e]&&f[e].points;d.push(Array.isArray(n)?n:[])}return{o:a,h:o,m:s,l:c,c:u,points:d}}parseDataAxisCharts(e){var t,n,r,i,a,o;let u=this.w.config,d=this.w.globals,f=new DateTime(this.w);this.w.seriesData._parsedExtrema=[];let p=u.labels.length>0?u.labels.slice():u.xaxis.categories.slice();this.w.axisFlags.isRangeBar=u.chart.type===`rangeBar`&&d.isBarHorizontal,this.w.labelData.hasXaxisGroups=u.xaxis.type===`category`&&u.xaxis.group.groups.length>0,this.w.labelData.hasXaxisGroups&&(this.w.labelData.groups=u.xaxis.group.groups),e.forEach((e,t)=>{e.name===void 0?this.w.seriesData.seriesNames.push(`series-`+parseInt(String(t+1),10)):this.w.seriesData.seriesNames.push(e.name)}),this.coreUtils.setSeriesYAxisMappings();let m=[],h=[...new Set(u.series.map(e=>e.group))];u.series.forEach((e,t)=>{let n=h.indexOf(e.group);m[n]||(m[n]=[]),m[n].push(this.w.seriesData.seriesNames[t])}),this.w.labelData.seriesGroups=m;let g=()=>{for(let e=0;e<p.length;e++)if(typeof p[e]==`string`)if(f.isValidDate(p[e]))this.twoDSeriesX.push(f.parseDate(p[e]));else throw Error(`You have provided invalid Date format. Please provide a valid JavaScript Date`);else this.twoDSeriesX.push(p[e])};for(let f=0;f<e.length;f++){this.twoDSeries=[],this.twoDSeriesX=[],this.threeDSeries=[],e[f].data===void 0&&(console.error(`It is a possibility that you may have not included 'data' property in series.`),e[f]=c(s({},e[f]),{data:[]}));let m=u.chart.dataReducer,h=(n=(t=d.dataReducerRawSeries)==null?void 0:t[f])==null?void 0:n.data;if(m!=null&&m.enabled&&this.isMultiFormat()&&Array.isArray(h)&&h.length>((r=m.threshold)==null?500:r)){let t=(i=m.targetPoints)==null?250:i,n=u.xaxis.min,r=u.xaxis.max,d=n==null&&r==null?h:Data.sliceByXRange(h,n,r),p=d;if(d.length>t){let e=Array.isArray(d[0])?(o=d[0])==null?void 0:o[1]:(a=d[0])==null?void 0:a.y;Array.isArray(e)?e.length===4?p=Data.ohlcAggregate(d,t):e.length===2&&(p=Data.rangeAggregate(d,t)):p=Data.lttbDownsample(d,t)}e[f]=c(s({},e[f]),{data:p})}(u.chart.type===`rangeBar`||u.chart.type===`rangeArea`||e[f].type===`rangeBar`||e[f].type===`rangeArea`)&&(this.w.axisFlags.isRangeData=!0,this.handleRangeData(e,f));let v=e[f].type||u.chart.type;if(X(v)){let t=Z(v),n=t&&t.yExtent;(t&&t.dataType===`rangeXY`||typeof n==`function`)&&(this.w.axisFlags.isRangeData=!0,this.handleCustomRangeData(e,f,n))}if(this.isMultiFormat())this.isFormat2DArray()?this.handleFormat2DArray(e,f):this.isFormatXY()&&this.handleFormatXY(e,f),(u.chart.type===`candlestick`||e[f].type===`candlestick`||u.chart.type===`boxPlot`||e[f].type===`boxPlot`)&&this.handleCandleStickBoxData(e,f),(u.chart.type===`violin`||e[f].type===`violin`)&&this.handleViolinData(e,f),this.w.seriesData.series.push(this.twoDSeries),this.w.labelData.labels.push(this.twoDSeriesX),this.w.seriesData.seriesX.push(this.twoDSeriesX),this.w.seriesData.seriesGoals=this.seriesGoals,f===this.activeSeriesIndex&&!this.fallbackToCategory&&(this.w.axisFlags.isXNumeric=!0);else{u.xaxis.type===`datetime`?(this.w.axisFlags.isXNumeric=!0,g(),this.w.seriesData.seriesX.push(this.twoDSeriesX)):u.xaxis.type===`numeric`&&(this.w.axisFlags.isXNumeric=!0,p.length>0&&(this.twoDSeriesX=p,this.w.seriesData.seriesX.push(this.twoDSeriesX))),this.w.labelData.labels.push(this.twoDSeriesX);let t=e[f].data.map(e=>_.parseNumber(e));this.w.seriesData.series.push(t)}this.w.seriesData.seriesZ.push(this.threeDSeries),e[f].color===void 0?this.w.seriesData.seriesColors.push(void 0):this.w.seriesData.seriesColors.push(e[f].color)}return this.w}parseDataNonAxisCharts(e){let t=this.w.config;this.w.seriesData.unitData=[];let n=Array.isArray(e)&&e.every(e=>typeof e==`number`)&&t.labels.length>0,r=Array.isArray(e)&&e.some(e=>e&&typeof e==`object`&&e.data||e&&typeof e==`object`&&e.parsing);if(t.chart.type===`unit`&&r&&!n)return this.parseUnitSeries(e);if(n&&r&&console.warn(`ApexCharts: Both old format (numeric series + labels) and new format (series objects with data/parsing) detected. Using old format for backward compatibility.`),n){this.w.seriesData.series=e.slice(),this.w.seriesData.seriesNames=t.labels.slice();for(let e=0;e<this.w.seriesData.series.length;e++)this.w.seriesData.seriesNames[e]===void 0&&this.w.seriesData.seriesNames.push(`series-`+(e+1));return this.w}if(Array.isArray(e)&&e.every(e=>typeof e==`number`)){this.w.seriesData.series=e.slice(),this.w.seriesData.seriesNames=[];for(let e=0;e<this.w.seriesData.series.length;e++)this.w.seriesData.seriesNames.push(t.labels[e]||`series-${e+1}`);return this.w}let i=this.extractPieDataFromSeries(e);this.w.seriesData.series=i.values,this.w.seriesData.seriesNames=i.labels,t.chart.type===`radialBar`&&(this.w.seriesData.series=this.w.seriesData.series.map(e=>{let t=_.parseNumber(e);return t>100&&console.warn(`ApexCharts: RadialBar value ${t} > 100, consider using percentage values (0-100)`),t}));for(let e=0;e<this.w.seriesData.series.length;e++)this.w.seriesData.seriesNames[e]===void 0&&this.w.seriesData.seriesNames.push(`series-`+(e+1));return this.w}parseUnitSeries(e){let t=this.w.config,n=[],r=[],i=[];return e.forEach((e,a)=>{var o;let s=e&&Array.isArray(e.data)?e.data:[];n.push(s.length);let c=e&&e.name!==void 0&&e.name!==null?e.name:void 0;r.push((o=c==null?t.labels[a]:c)==null?`series-${a+1}`:o),i.push(s.slice())}),this.w.seriesData.series=n,this.w.seriesData.seriesNames=r,this.w.seriesData.unitData=i,this.w}resetParsingFlags(){let e=this.w;e.axisFlags.dataWasParsed=!1,e.globals.originalSeries=null,e.config.series&&e.config.series.forEach(e=>{e.__apexParsed&&delete e.__apexParsed})}extractPieDataFromSeries(e){let t=[],n=[];if(!Array.isArray(e))return console.warn(`ApexCharts: Expected array for series data`),{values:[],labels:[]};if(e.length===0)return console.warn(`ApexCharts: Empty series array`),{values:[],labels:[]};let r=e[0];if(typeof r==`object`&&r&&r.data)this.extractPieDataFromSeriesObjects(e,t,n);else return console.warn(`ApexCharts: Unsupported series format for pie/donut/radialBar. Expected series objects with data property.`),{values:[],labels:[]};return{values:t,labels:n}}extractPieDataFromSeriesObjects(e,t,n){e.forEach((e,r)=>{if(!e.data||!Array.isArray(e.data)){console.warn(`ApexCharts: Series ${r} has no valid data array`);return}e.data.forEach(e=>{typeof e==`object`&&e?e.x!==void 0&&e.y!==void 0?(n.push(String(e.x)),t.push(_.parseNumber(e.y))):console.warn(`ApexCharts: Invalid data point format for pie chart. Expected {x, y} format:`,e):console.warn(`ApexCharts: Expected object data point, got:`,typeof e)})})}handleExternalLabelsData(e){let t=this.w.config;if(t.xaxis.categories.length>0)this.w.labelData.labels=t.xaxis.categories;else if(t.labels.length>0)this.w.labelData.labels=t.labels.slice();else if(this.fallbackToCategory){if(this.w.labelData.labels=this.w.labelData.labels[0],this.w.rangeData.seriesRange.length){this.w.rangeData.seriesRange.map(e=>{e.forEach(e=>{this.w.labelData.labels.indexOf(e.x)<0&&e.x&&this.w.labelData.labels.push(e.x)})});let e=this.w.labelData.labels;if(e.length>0&&(typeof e[0]==`number`||typeof e[0]==`string`))this.w.labelData.labels=[...new Set(e)];else{let t=/* @__PURE__ */ new Map;for(let n of e){let e=JSON.stringify(n);t.has(e)||t.set(e,n)}this.w.labelData.labels=Array.from(t.values())}}t.xaxis.convertedCatToNumeric&&(new Defaults(t).convertCatToNumericXaxis(t,this.w.seriesData.seriesX[0]),this._generateExternalLabels(e))}else this._generateExternalLabels(e)}_generateExternalLabels(e){let t=this.w.globals,n=this.w.config,r=[];if(t.axisCharts){if(this.w.seriesData.series.length>0)if(this.isFormatXY()){let e=n.series.map(e=>{let t=/* @__PURE__ */ new Map;for(let n of e.data)t.has(n.x)||t.set(n.x,n);return Array.from(t.values())}),t=e.reduce((e,t,n,r)=>r[e].length>t.length?e:n,0);for(let n=0;n<e[t].length;n++)r.push(n+1)}else for(let e=0;e<this.w.seriesData.series[t.maxValsInArrayIndex].length;e++)r.push(e+1);this.w.seriesData.seriesX=[];for(let t=0;t<e.length;t++)this.w.seriesData.seriesX.push(r);this.w.globals.isBarHorizontal||(this.w.axisFlags.isXNumeric=!0)}if(r.length===0){r=t.axisCharts?[]:this.w.seriesData.series.map((e,t)=>t+1);for(let t=0;t<e.length;t++)this.w.seriesData.seriesX.push(r)}this.w.labelData.labels=r,n.xaxis.convertedCatToNumeric&&(this.w.labelData.categoryLabels=r.map(e=>n.xaxis.labels.formatter(e))),this.w.axisFlags.noLabelsProvided=!0}parseRawDataIfNeeded(e){let t=this.w.config,n=this.w.globals,r=t.parsing;if(this.w.axisFlags.dataWasParsed)return e;let i=!!(r&&(r.x||r.y||r.z)),a=e.some(e=>e.parsing&&(e.parsing.x||e.parsing.y||e.parsing.z));if(!i&&!a)return e;let o=e.map((e,t)=>{var n,i,a,o,u;if(!e.data||!Array.isArray(e.data)||e.data.length===0)return e;let d={x:((n=e.parsing)==null?void 0:n.x)||(r==null?void 0:r.x),y:((i=e.parsing)==null?void 0:i.y)||(r==null?void 0:r.y),z:((a=e.parsing)==null?void 0:a.z)||(r==null?void 0:r.z)};if(!d.x&&!d.y)return e;let f=e.data[0];if(typeof f==`object`&&f&&(Object.prototype.hasOwnProperty.call(f,`x`)||Object.prototype.hasOwnProperty.call(f,`y`))||Array.isArray(f))return e;if(!d.x||!d.y||Array.isArray(d.y)&&d.y.length===0){let n=[];d.x||n.push(`x`),(!d.y||Array.isArray(d.y)&&d.y.length===0)&&n.push(`y`);let i=(o=e.name)==null?`series[${t}]`:o;return console.warn(`ApexCharts [${this.w.globals.chartID}]: "${i}" has a parseData config but is missing the '${n.join(`', '`)}' field specification.`,{parsing:(u=e.parsing)==null?r:u}),e}let p=e.data.map((e,n)=>{if(typeof e!=`object`||!e)return console.warn(`ApexCharts: Series ${t}, data point ${n} is not an object, skipping parsing`),e;let r=this.getNestedValue(e,d.x),i,a;if(Array.isArray(d.y)){let n=d.y.map(t=>this.getNestedValue(e,t));this.w.config.chart.type===`bubble`?(n.length<2&&console.warn(`ApexCharts: series[${t}] bubble chart requires parseData.y to have at least 2 fields (y and z). Got: ${JSON.stringify(d.y)}`),i=n[0]):i=n}else i=this.getNestedValue(e,d.y);d.z&&(a=this.getNestedValue(e,d.z)),r===void 0&&console.warn(`ApexCharts: Series ${t}, data point ${n} missing field '${d.x}'`),i===void 0&&console.warn(`ApexCharts: Series ${t}, data point ${n} missing field '${d.y}'`);let o={x:r,y:i,z:void 0};if(this.w.config.chart.type===`bubble`&&Array.isArray(d.y)&&d.y.length===2){let t=this.getNestedValue(e,d.y[1]);t!==void 0&&(o.z=t)}return a!==void 0&&(o.z=a),o});return c(s({},e),{data:p,__apexParsed:!0})});return this.w.axisFlags.dataWasParsed=!0,n.originalSeries||(n.originalSeries=_.clone(e)),o}getNestedValue(e,t){if(!e||typeof e!=`object`||!t)return;if(t.indexOf(`.`)===-1)return e[t];let n=t.split(`.`),r=e;for(let e=0;e<n.length;e++){if(typeof r!=`object`||!r)return;r=r[n[e]]}return r}applySeriesTransform(e){let t=this.w.config,n=t.chart.requestedType||t.chart.type;n!==`waterfall`&&this.w.waterfallData.geometry&&(this.w.waterfallData={values:[],cumulative:[],kinds:[],geometry:null}),n!==`dumbbell`&&this.w.dumbbellData&&(this.w.dumbbellData=null),n!==`streamgraph`&&this.w.streamgraphData&&(this.w.streamgraphData=null);let r=Xt(n);if(r)return r(e,this.w);let i=cn[n];return!Array.isArray(e)||!i?e:(this._warnedMissingTransform||(this._warnedMissingTransform=!0,console.warn(`ApexCharts: chart.type '${n}' requires the ${i} feature, which is not in this bundle. Bundler: import 'apexcharts/features/${i}' (or from 'apexcharts/${n}'). Script tag: add <script src='.../dist/features/${i}.js'> after apexcharts.js.`)),e.map(e=>c(s({},e),{data:[]})))}flattenTreemapHierarchy(e){let t=this.w,n=t.globals;if(t.config.chart.type!==`treemap`||!Array.isArray(e))return e;if(!n.treemapRawSeries){if(!rn(t,e))return n.treemapRoots=null,e;n.treemapRawSeries=e.map(e=>c(s({},e),{data:Array.isArray(e==null?void 0:e.data)?e.data.slice():e==null?void 0:e.data}))}let{roots:r,leafSeries:i,maxDepth:a}=sn(t,n.treemapRawSeries);return n.treemapRoots=r,n.treemapMaxDepth=a,i}expandScatterJitterData(e){var t,n;let r=this.w.config,i=r.chart.type===`scatter`||r.chart.type===`bubble`,a=(n=(t=r.plotOptions)==null?void 0:t.scatter)==null?void 0:n.jitter;if(!i||!a||!a.enabled||!Array.isArray(e))return e;if(!e.some(e=>Array.isArray(e==null?void 0:e.data)&&e.data.some(e=>e&&!Array.isArray(e)&&Array.isArray(e.y))))return r.xaxis.type!==`datetime`&&(Array.isArray(r.xaxis.categories)&&r.xaxis.categories.length?this._applyBandAxis(r.xaxis.categories.slice()):Array.isArray(r.xaxis._scatterBandLabels)&&r.xaxis._scatterBandLabels.length&&this._applyBandAxis(r.xaxis._scatterBandLabels)),e;let o=[],u=/* @__PURE__ */ new Map;e.forEach(e=>{Array.isArray(e==null?void 0:e.data)&&e.data.forEach(e=>{if(e&&Array.isArray(e.y)){let t=String(e.x);u.has(t)||(u.set(t,o.length),o.push(e.x))}})});let d=a.maxPoints||5e3,f=e.map(e=>{if(!Array.isArray(e==null?void 0:e.data))return e;let t=[];return e.data.forEach(e=>{if(e&&Array.isArray(e.y)){let n=u.get(String(e.x)),r=e.y,i=r.length>d?Math.ceil(r.length/d):1;for(let e=0;e<r.length;e+=i){let i=_.parseNumber(r[e]);i!==null&&t.push({x:n,y:i})}}else if(e&&typeof e==`object`&&!Array.isArray(e)){let n=String(e.x);t.push({x:u.has(n)?u.get(n):e.x,y:e.y})}else t.push(e)}),c(s({},e),{data:t})});return this._applyBandAxis(o),f}_applyBandAxis(e){var t;let n=this.w.config.xaxis,r=e.length;if(!r)return;let i=n._scatterBand=n._scatterBand||{};if(n._scatterBandLabels=e.slice(),n.type=`numeric`,(t=this.w.interact)!=null&&t.zoomed&&typeof n.min==`number`&&typeof n.max==`number`&&isFinite(n.min)&&isFinite(n.max)){let e=e=>Math.max(0,Math.min(r-1,e)),t=e(Math.round(n.min+.49)),a=e(Math.round(n.max-.49));a<t&&(t=a=e(Math.round((n.min+n.max)/2))),n.min=t-1,n.max=a+1,n.tickAmount=a-t+2,i.min=!0,i.max=!0,i.tick=!0}else (n.min==null||i.min)&&(n.min=-1,i.min=!0),(n.max==null||i.max)&&(n.max=r,i.max=!0),(n.tickAmount==null||n.tickAmount===`dataPoints`||i.tick)&&(n.tickAmount=r+1,i.tick=!0);n.labels=n.labels||{};let a=n.labels.formatter;if(typeof a!=`function`||a._scatterBand){let t=(t=>{let n=Math.round(t);return Math.abs(t-n)<1e-6&&e[n]!==void 0?e[n]:``});t._scatterBand=!0,n.labels.formatter=t}}parseData(e){var t,n,r,i,a,o,u;let d=this.w,f=d.config,p=d.globals;if(e=this.parseRawDataIfNeeded(e),e=this.applySeriesTransform(e),e=this.expandScatterJitterData(e),e=this.flattenTreemapHierarchy(e),(t=f.chart.dataReducer)!=null&&t.enabled&&p.axisCharts&&!p.dataReducerRawSeries){p.dataReducerRawSeries=e.map(e=>({data:Array.isArray(e==null?void 0:e.data)?e.data.slice():e==null?void 0:e.data}));let t=1/0,o=-1/0;for(let s of e){let e=s==null?void 0:s.data;if(!Array.isArray(e)||e.length===0)continue;let c=!Array.isArray(e[0]),u=c?(n=e[0])==null?void 0:n.x:(r=e[0])==null?void 0:r[0],d=c?(i=e[e.length-1])==null?void 0:i.x:(a=e[e.length-1])==null?void 0:a[0];typeof u==`number`&&(t=Math.min(t,u)),typeof d==`number`&&(o=Math.max(o,d))}t!==1/0&&(p.dataReducerRawMinX=t,p.dataReducerRawMaxX=o)}if(p.dataReducerRawSeries&&(o=f.chart.dataReducer)!=null&&o.enabled&&(e=e.map(e=>s({},e))),f.series=e,p.dataReducerRawSeries&&(u=f.chart.dataReducer)!=null&&u.enabled){let t=p.dataReducerRawSeries;p.initialSeries=e.map((e,n)=>{var r,i,a;return c(s({},e),{data:(a=(i=(r=t[n])==null?void 0:r.data)==null?void 0:i.slice())==null?e.data:a})})}else p.histogramRawSeries?p.initialSeries=p.histogramRawSeries:p.dumbbellRawSeries?p.initialSeries=p.dumbbellRawSeries:p.streamgraphRawSeries?p.initialSeries=p.streamgraphRawSeries:p.waterfallRawSeries?p.initialSeries=p.waterfallRawSeries:p.treemapRawSeries?p.initialSeries=p.treemapRawSeries:p.initialSeries=e;if(this.excludeCollapsedSeriesInYAxis(),this.fallbackToCategory=!1,this.resetGlobals(),this.isMultipleY(),p.axisCharts?(this.parseDataAxisCharts(e),this.coreUtils.getLargestSeries()):this.parseDataNonAxisCharts(e),f.chart.stacked){let e=new Series(this.w);this.w.seriesData.series=e.setNullSeriesToZeroValues(this.w.seriesData.series)}this.coreUtils.getSeriesTotals(),p.axisCharts?(Data._defineLazyResult(this.w.seriesData,`stackedSeriesTotals`,()=>this.coreUtils.getStackedSeriesTotals()),Data._defineLazyResult(this.w.seriesData,`stackedSeriesTotalsByGroups`,()=>this.coreUtils.getStackedSeriesTotalsByGroups()),Data._defineLazyResult(p,`seriesPercent`,()=>(this.coreUtils.getPercentSeries(),p.seriesPercent))):this.coreUtils.getPercentSeries(),!this.w.axisFlags.dataFormatXNumeric&&(!this.w.axisFlags.isXNumeric||f.xaxis.type===`numeric`&&f.labels.length===0&&f.xaxis.categories.length===0)&&this.handleExternalLabelsData(e);let m=this.coreUtils.getCategoryLabels(this.w.labelData.labels);for(let e=0;e<m.length;e++)if(Array.isArray(m[e])){this.w.axisFlags.isMultiLineX=!0;break}return{seriesData:{series:this.w.seriesData.series,seriesNames:this.w.seriesData.seriesNames,seriesX:this.w.seriesData.seriesX,seriesZ:this.w.seriesData.seriesZ,seriesColors:this.w.seriesData.seriesColors,seriesGoals:this.w.seriesData.seriesGoals,unitData:this.w.seriesData.unitData,noLabelsProvided:this.w.axisFlags.noLabelsProvided},rangeData:{seriesRangeStart:this.w.rangeData.seriesRangeStart,seriesRangeEnd:this.w.rangeData.seriesRangeEnd,seriesRange:this.w.rangeData.seriesRange},candleData:{seriesCandleO:this.w.candleData.seriesCandleO,seriesCandleH:this.w.candleData.seriesCandleH,seriesCandleM:this.w.candleData.seriesCandleM,seriesCandleL:this.w.candleData.seriesCandleL,seriesCandleC:this.w.candleData.seriesCandleC,seriesBoxPoints:this.w.candleData.seriesBoxPoints},labelData:{labels:this.w.labelData.labels,categoryLabels:this.w.labelData.categoryLabels},axisFlags:{isXNumeric:this.w.axisFlags.isXNumeric,dataFormatXNumeric:this.w.axisFlags.dataFormatXNumeric,isDataXYZ:this.w.axisFlags.isDataXYZ,isRangeData:this.w.axisFlags.isRangeData,isRangeBar:this.w.axisFlags.isRangeBar,isMultiLineX:this.w.axisFlags.isMultiLineX,dataWasParsed:this.w.axisFlags.dataWasParsed,hasXaxisGroups:this.w.labelData.hasXaxisGroups,groups:this.w.labelData.groups,seriesGroups:this.w.labelData.seriesGroups}}}static _defineLazyResult(e,t,n){let r=!1,i;Object.defineProperty(e,t,{configurable:!0,enumerable:!0,get(){return r||(r=!0,i=n()),i},set(e){r=!0,i=e}})}static sliceByXRange(e,t,n){let r=e.length;if(r===0)return e;let i=Array.isArray(e[0])?e=>e[0]:e=>e.x,a=0;if(t!=null){let n=0,o=r-1;for(;n<=o;){let r=n+o>>1;i(e[r])<t?n=r+1:o=r-1}a=Math.max(0,n-1)}let o=r;if(n!=null){let t=0,a=r-1;for(;t<=a;){let r=t+a>>1;i(e[r])>n?a=r-1:t=r+1}o=Math.min(r,t+1)}return a===0&&o===r?e.slice():e.slice(a,o)}static lttbDownsample(e,t){let n=e.length;if(t>=n||t<3)return e;let r=!Array.isArray(e[0]),i=r?e=>e.x:e=>e[0],a=r?e=>e.y:e=>e[1],o=[];o.push(e[0]);let s=(n-2)/(t-2),c=0;for(let r=0;r<t-2;r++){let t=Math.floor((r+1)*s)+1,u=Math.min(Math.floor((r+2)*s)+1,n),d=0,f=0,p=u-t;for(let n=t;n<u;n++)d+=i(e[n]),f+=a(e[n]);d/=p,f/=p;let m=Math.floor(r*s)+1,h=Math.min(Math.floor((r+1)*s)+1,n),g=i(e[c]),_=a(e[c]),v=-1,y=m;for(let t=m;t<h;t++){let n=Math.abs((g-d)*(a(e[t])-_)-(g-i(e[t]))*(f-_))*.5;n>v&&(v=n,y=t)}o.push(e[y]),c=y}return o.push(e[n-1]),o}static ohlcAggregate(e,t){let n=e.length;if(t>=n||t<1)return e;let r=!Array.isArray(e[0]),i=r?e=>e.x:e=>e[0],a=r?e=>e.y:e=>e[1],o=r?(e,t)=>({x:e,y:t}):(e,t)=>[e,t],s=[],c=n/t;for(let r=0;r<t;r++){let u=Math.floor(r*c),d=r===t-1?n:Math.floor((r+1)*c);if(d<=u)continue;let f=a(e[u]),p=f[0],m=f[1],h=f[2],g=f[3];for(let t=u+1;t<d;t++){let n=a(e[t]);n[1]>m&&(m=n[1]),n[2]<h&&(h=n[2]),g=n[3]}s.push(o(i(e[u]),[p,m,h,g]))}return s}static rangeAggregate(e,t){let n=e.length;if(t>=n||t<1)return e;let r=!Array.isArray(e[0]),i=r?e=>e.x:e=>e[0],a=r?e=>e.y:e=>e[1],o=r?(e,t)=>({x:e,y:t}):(e,t)=>[e,t],s=[],c=n/t;for(let r=0;r<t;r++){let u=Math.floor(r*c),d=r===t-1?n:Math.floor((r+1)*c);if(d<=u)continue;let f=1/0,p=-1/0;for(let t=u;t<d;t++){let n=a(e[t]);if(n!=null)for(let e=0;e<2;e++){let t=n[e];t==null||!isFinite(t)||(t<f&&(f=t),t>p&&(p=t))}}s.push(o(i(e[u]),f===1/0?[null,null]:[f,p]))}return s}excludeCollapsedSeriesInYAxis(){let e=this.w,t=[];e.globals.seriesYAxisMap.forEach((n,r)=>{let i=0;n.forEach(t=>{e.globals.collapsedSeriesIndices.indexOf(t)!==-1&&i++}),i>0&&i==n.length&&t.push(r)}),e.globals.ignoreYAxisIndexes=t.map(e=>e)}}class UpdateHelpers{constructor(e,t){this.w=e,this.ctx=t}_updateOptions(e,t=!1,n=!0,r=!0,i=!1){return new Promise((a,o)=>{let s=[this.ctx];r&&(s=this.ctx.getSyncedCharts()),this.w.globals.isExecCalled&&(s=[this.ctx],this.w.globals.isExecCalled=!1),s.forEach((r,c)=>{var u,d;let f=r.w;f.globals.shouldAnimate=n,t||(f.globals.resized=!0,f.globals.dataChanged=!0,n&&f.config.chart.animations.enabled&&r.series.getPreviousPaths());let p=f.config.chart.requestedType||f.config.chart.type;if(n&&e&&typeof e==`object`){let t=(u=e==null?void 0:e.chart)==null?void 0:u.type;t&&t!==p&&((d=r.morphTypeChange)==null||d.captureBeforeDestroy({fromType:p,toType:t,newSeries:e.series||f.config.series}))}if(e&&typeof e==`object`){r.config=new Config(e);let t=e.chart&&e.chart.type,n=t===`funnel`||t===`pyramid`||t===`gauge`,a=!!f.config.chart.requestedType;if(t&&!n&&a){e.chart=e.chart||{},e.chart.requestedType=t;let n=f.config.chart.requestedType;(n===`funnel`||n===`pyramid`)&&(e.plotOptions=e.plotOptions||{},e.plotOptions.bar=e.plotOptions.bar||{},e.plotOptions.bar.isFunnel===void 0&&(e.plotOptions.bar.isFunnel=!1),e.plotOptions.bar.isPyramid===void 0&&(e.plotOptions.bar.isPyramid=!1))}if(r.config.normalizeAliasedChartType(e),e=CoreUtils.extendArrayProps(r.config,e,f),r.w.globals.chartID!==this.w.globals.chartID&&(delete e.series,delete e.yaxis),f.config=_.extend(f.config,e),Defaults.handOverTypeDefaults(f.config,p,e),i){f.globals.lastXAxis=e.xaxis?_.clone(e.xaxis):[],f.globals.lastYAxis=e.yaxis?_.clone(e.yaxis):[];let t=f.globals.initialConfig&&f.globals.initialConfig.series,n=_.extend({},f.config);n.series=!e.series&&t?t:_.copySeriesShallow(f.config.series),f.globals.initialConfig=n,f.globals.initialSeries=f.config.series}e.series&&(f.globals.collapsedSeriesIndices.length>0||f.globals.ancillaryCollapsedSeriesIndices.length>0)&&r.series.reconcileCollapsedByName()}return r.update(e).then(()=>{c===s.length-1&&a(r)}).catch(o)})})}_updateSeries(e,t,n=!1){return new Promise((r,i)=>{let a=this.w;a.globals.shouldAnimate=t,a.globals.dataChanged=!0;let o=JSON.stringify({y:(a.globals.yAxisScale||[]).map(e=>e?e.result:null),xMin:a.globals.minX,xMax:a.globals.maxX});PerformanceCache.invalidateSelectors(a),t&&a.config.chart.animations.enabled&&this.ctx.series.getPreviousPaths();let c=a.config.series.length,u=a.config.series.map(e=>{var t,n;return(n=(t=e==null?void 0:e.data)==null?void 0:t.length)==null?0:n});n&&(a.globals.dataReducerRawSeries=null,a.globals.histogramRawSeries=null,a.globals.waterfallRawSeries=null,a.globals.dumbbellRawSeries=null,a.globals.streamgraphRawSeries=null,a.globals.treemapRawSeries=null),a.globals.axisCharts&&(a.globals.collapsedSeriesIndices.length>0||a.globals.ancillaryCollapsedSeriesIndices.length>0)&&(e=e.map(e=>e&&typeof e==`object`?s({},e):e),this.ctx.series.reconcileCollapsedByName(e)),this.ctx.data.resetParsingFlags();let d=this.ctx.data.parseData(e);return this.ctx._writeParsedSeriesData(d.seriesData),this.ctx._writeParsedRangeData(d.rangeData),this.ctx._writeParsedCandleData(d.candleData),this.ctx._writeParsedLabelData(d.labelData),this.ctx._writeParsedAxisFlags(d.axisFlags),n&&(a.globals.initialConfig&&(a.globals.initialConfig.series=_.copySeriesShallow(a.config.series)),a.globals.initialSeries=a.config.series),this._canUseFastPath(e,c,u,a)?this.ctx.fastUpdate(t,o).then(()=>{r(this.ctx)}).catch(i):(this.ctx._updateStats&&this.ctx._updateStats.full++,this.ctx.update().then(()=>{r(this.ctx)}).catch(i))})}_canUseFastPath(e,t,n,r){return!(!r.dom.elGraphical||!r.globals.axisCharts||e.length!==t||e.some((e,t)=>{var r,i;return((i=(r=e==null?void 0:e.data)==null?void 0:r.length)==null?0:i)!==n[t]})||r.globals.collapsedSeries.length>0||r.globals.ancillaryCollapsedSeries.length>0||r.globals.risingSeries.length>0||r.globals.comboCharts||r.interact.zoomed)}_extendSeries(e,t){let n=this.w,r=n.config.series[t];return c(s({},n.config.series[t]),{name:e.name?e.name:r==null?void 0:r.name,color:e.color?e.color:r==null?void 0:r.color,type:e.type?e.type:r==null?void 0:r.type,group:e.group?e.group:r==null?void 0:r.group,hidden:e.hidden===void 0?r==null?void 0:r.hidden:e.hidden,data:e.data?e.data:r==null?void 0:r.data,zIndex:e.zIndex===void 0?t:e.zIndex})}toggleDataPointSelection(e,t){let n=this.w,r=null,i=`.apexcharts-series[data\\:realIndex='${e}']`;if(n.globals.axisCharts?r=n.dom.Paper.findOne(`${i} path[j='${t}'], ${i} circle[j='${t}'], ${i} rect[j='${t}']`):t===void 0&&(r=n.dom.Paper.findOne(`${i} path[j='${e}']`),(n.config.chart.type===`pie`||n.config.chart.type===`polarArea`||n.config.chart.type===`donut`)&&this.ctx.pie.pieClicked(e)),r)new Graphics(this.w).pathMouseDown(r,null);else return console.warn(`toggleDataPointSelection: Element not found`),null;return r.node?r.node:null}forceXAxisUpdate(e){let t=this.w;return[`min`,`max`].forEach(n=>{e.xaxis[n]!==void 0&&(t.config.xaxis[n]=e.xaxis[n],t.globals.lastXAxis[n]=e.xaxis[n])}),e.xaxis.categories&&e.xaxis.categories.length&&(t.config.xaxis.categories=e.xaxis.categories),t.config.xaxis.convertedCatToNumeric&&(e=new Defaults(e).convertCatToNumericXaxis(e,this.ctx)),e}forceYAxisUpdate(e){return e.chart&&e.chart.stacked&&e.chart.stackType===`100%`&&(Array.isArray(e.yaxis)?e.yaxis.forEach((t,n)=>{e.yaxis[n].min=0,e.yaxis[n].max=100}):(e.yaxis.min=0,e.yaxis.max=100)),e}revertDefaultAxisMinMax(e){let t=this.w,n=t.globals.lastXAxis,r=t.globals.lastYAxis;e&&e.xaxis&&(n=e.xaxis),e&&e.yaxis&&(r=e.yaxis);let i=n;t.config.xaxis.min=i.min,t.config.xaxis.max=i.max;let a=e=>{if(r[e]!==void 0){let n=r[e];t.config.yaxis[e].min=n.min,t.config.yaxis[e].max=n.max}};t.config.yaxis.map((e,n)=>{t.interact.zoomed?a(n):r[n]===void 0?this.ctx.opts.yaxis[n]!==void 0&&(e.min=this.ctx.opts.yaxis[n].min,e.max=this.ctx.opts.yaxis[n].max):a(n)})}}class AxisMapping{static xRatio(e){let t=e.layout.gridWidth||1;return(e.globals.maxX-e.globals.minX)/t}static dataXToPx(e,t){return(t-e.globals.minX)/AxisMapping.xRatio(e)}static pxToDataX(e,t){return e.globals.minX+t*AxisMapping.xRatio(e)}static screenXToPlotPx(e,t){let n=e.dom.baseEl,r=n&&n.querySelector(`.apexcharts-svg`);if(!r)return t-e.layout.translateX;let i=r.getBoundingClientRect(),a=e.globals.svgWidth?i.width/e.globals.svgWidth:1;return(t-i.left)/(a||1)-e.layout.translateX}}class Utils2{constructor(e){this.w=e.w,this.ttCtx=e}static hoverTarget(e){return e?(e.eventPhase&&e.target&&(e.apexHoverTarget=e.target),e.apexHoverTarget||e.target):null}getNearestValues({hoverArea:e,elGrid:t,clientX:n,clientY:r}){var i;let a=this.w,o=t.getBoundingClientRect(),s=a.layout.gridWidth,c=o.height,u=s/(a.globals.dataPoints-1),d=c/a.globals.dataPoints,f=this.hasBars();(a.globals.comboCharts||f)&&!a.config.xaxis.convertedCatToNumeric&&(u=s/a.globals.dataPoints);let p=AxisMapping.screenXToPlotPx(a,n),m=r-o.top,h=a.globals.barPadForNumericAxis||0;p<-h||m<0||p>s+h||m>c?(e.classList.remove(`hovering-zoom`),e.classList.remove(`hovering-pan`)):a.interact.zoomEnabled?(e.classList.remove(`hovering-pan`),e.classList.add(`hovering-zoom`)):a.interact.panEnabled&&(e.classList.remove(`hovering-zoom`),e.classList.add(`hovering-pan`));let g=Math.round(p/u),v=Math.floor(m/d);f&&!a.config.xaxis.convertedCatToNumeric&&(g=Math.ceil(p/u),--g);let y=null,b=null,x=a.globals.seriesXvalues.map(e=>e.filter(e=>_.isNumber(e))),S=a.globals.seriesYvalues.map(e=>e.filter(e=>_.isNumber(e)));if(a.axisFlags.isXNumeric){b=this.closestInMultiArray(p,m,x,S),y=b.index,g=(i=b.j)==null?0:i;let e=x.some((e,t)=>e.length!==a.globals.seriesXvalues[t].length);if(y!==null&&e){let e=a.globals.seriesXvalues[y],t=null,n=1/0;for(let r=0;r<e.length;r++){if(!_.isNumber(e[r]))continue;let i=Math.abs(p-e[r]);i<n&&(n=i,t=r)}t!==null&&(g=t)}}return a.interact.capturedSeriesIndex=y===null?-1:y,(!g||g<1)&&(g=0),a.globals.isBarHorizontal?a.interact.capturedDataPointIndex=v:a.interact.capturedDataPointIndex=g,{capturedSeries:y,j:a.globals.isBarHorizontal?v:g,hoverX:p,hoverY:m}}getFirstActiveXArray(e){let t=this.w,n=0,r=e.map((e,t)=>e.length>0?t:-1);for(let e=0;e<r.length;e++)if(r[e]!==-1&&t.globals.collapsedSeriesIndices.indexOf(e)===-1&&t.globals.ancillaryCollapsedSeriesIndices.indexOf(e)===-1){n=r[e];break}return n}closestInMultiArray(e,t,n,r){let i=this.w,a=e=>i.globals.collapsedSeriesIndices.indexOf(e)===-1&&i.globals.ancillaryCollapsedSeriesIndices.indexOf(e)===-1,o=i.config.chart.type,s=!i.globals.comboCharts&&(o===`line`||o===`area`),c=1/0,u=null,d=null;if(i.globals.allSeriesHasEqualX){let i=1/0;for(let t=0;t<n.length;t++){if(!a(t))continue;let o=n[t],s=r[t],c=Math.min(o.length,s.length);for(let t=0;t<c;t++){let n=Math.abs(e-o[t]);n<i&&(i=n,d=t)}}if(d!==null)if(s){let i=1/0;for(let o=0;o<n.length;o++){if(!a(o))continue;let s=n[o],c=r[o],f=Math.min(s.length,c.length);if(f<2){let e=c[d];if(typeof e!=`number`)continue;let n=Math.abs(t-e);n<i&&(i=n,u=o);continue}for(let n=0;n<f-1;n++){let r=this._distanceToSegment(e,t,s[n],c[n],s[n+1],c[n+1]);r.dist<i&&(i=r.dist,u=o)}}}else{let e=1/0;for(let i=0;i<n.length;i++){if(!a(i))continue;let n=r[i][d];if(typeof n!=`number`)continue;let o=Math.abs(t-n);o<e&&(e=o,u=i)}}return{index:u,j:d}}for(let i=0;i<n.length;i++){if(!a(i))continue;let o=n[i],f=r[i],p=Math.min(o.length,f.length);if(s&&p>=2){for(let n=0;n<p-1;n++){let r=this._distanceToSegment(e,t,o[n],f[n],o[n+1],f[n+1]);r.dist<c&&(c=r.dist,u=i,d=r.t<.5?n:n+1)}continue}for(let n=0;n<p;n++){let r=e-o[n],a=t-f[n],s=Math.sqrt(r*r+a*a);s<c&&(c=s,u=i,d=n)}}return{index:u,j:d}}_distanceToSegment(e,t,n,r,i,a){let o=i-n,s=a-r,c=o*o+s*s,u=c===0?0:((e-n)*o+(t-r)*s)/c;u<0?u=0:u>1&&(u=1);let d=n+u*o,f=r+u*s,p=e-d,m=t-f;return{dist:Math.sqrt(p*p+m*m),t:u}}closestInArray(e,t){let n=t[0],r=null,i=Math.abs(e-n);for(let n=0;n<t.length;n++){let a=Math.abs(e-t[n]);a<i&&(i=a,r=n)}return{j:r}}isXoverlap(e){let t=this.w,n=[],r=t.seriesData.seriesX.filter(e=>e[0]!==void 0);if(r.length>0)for(let t=0;t<r.length-1;t++)r[t][e]!==void 0&&r[t+1][e]!==void 0&&r[t][e]!==r[t+1][e]&&n.push(`unEqual`);return n.length===0}isInitialSeriesSameLen(){var e,t,n,r;let i=!0,a=((t=(e=this.w.globals._initialSeriesPeek)==null?this.w.globals.initialSeries:e)==null?void 0:t.filter((e,t)=>{var n;return!((n=this.w.globals.collapsedSeriesIndices)!=null&&n.includes(t))}))||[];for(let e=0;e<a.length-1;e++){if(!((n=a[e])!=null&&n.data)||!((r=a[e+1])!=null&&r.data))return!0;if(a[e].data.length!==a[e+1].data.length){i=!1;break}}return i}getBarsHeight(e){return[...e].reduce((e,t)=>e+t.getBBox().height,0)}getElMarkers(e){return typeof e==`number`?this.w.dom.baseEl.querySelectorAll(`.apexcharts-series[data\\:realIndex='${e}'] .apexcharts-series-markers-wrap > *`):this.w.dom.baseEl.querySelectorAll(`.apexcharts-series-markers-wrap > *`)}getAllMarkers(e=!1){let t=[...this.w.dom.baseEl.querySelectorAll(`.apexcharts-series-markers-wrap`)];e&&(t=t.filter(e=>{let t=Number(e.getAttribute(`data:realIndex`));return this.w.globals.collapsedSeriesIndices.indexOf(t)===-1})),t.sort((e,t)=>{var n=Number(e.getAttribute(`data:realIndex`)),r=Number(t.getAttribute(`data:realIndex`));return r<n?1:r>n?-1:0});let n=[];return t.forEach(e=>{n.push(e.querySelector(`.apexcharts-marker`))}),n}hasMarkers(e){return this.getElMarkers(e).length>0}getPathFromPoint(e,t){let n=Number(e.getAttribute(`cx`)),r=Number(e.getAttribute(`cy`)),i=e.getAttribute(`shape`);return new Graphics(this.w).getMarkerPath(n,r,i,t)}getElBars(){return this.w.dom.baseEl.querySelectorAll(`.apexcharts-bar-series,  .apexcharts-candlestick-series, .apexcharts-boxPlot-series, .apexcharts-violin-series, .apexcharts-rangebar-series`)}hasBars(){return this.getElBars().length>0}getHoverMarkerSize(e){let t=this.w,n=t.config.markers.hover.size;return n===void 0&&(n=t.globals.markers.size[e]+t.config.markers.hover.sizeOffset),n}toggleAllTooltipSeriesGroups(e){let t=this.w,n=this.ttCtx;n.allTooltipSeriesGroups.length===0&&(n.allTooltipSeriesGroups=t.dom.baseEl.querySelectorAll(`.apexcharts-tooltip-series-group`));let r=n.allTooltipSeriesGroups;for(let n=0;n<r.length;n++)e===`enable`?(r[n].classList.add(`apexcharts-active`),r[n].style.display=t.config.tooltip.items.display):(r[n].classList.remove(`apexcharts-active`),r[n].style.display=`none`)}}class Labels{constructor(e){this.w=e.w,this.ttCtx=e,this.tooltipUtil=new Utils2(e)}drawSeriesTexts({shared:e=!0,ttItems:t,i:n=0,j:r=null,y1:i,y2:a,e:o}){let s=this.w;s.config.tooltip.custom===void 0?this.toggleActiveInactiveSeries(e,n):this.handleCustomTooltip({i:n,j:r,y1:i,y2:a,w:s});let c=this.getValuesToPrint({i:n,j:r});this.printLabels({i:n,j:r,values:c,ttItems:t,shared:e,e:o});let u=this.ttCtx.getElTooltip();u&&(this.ttCtx.tooltipRect.ttWidth=u.getBoundingClientRect().width,this.ttCtx.tooltipRect.ttHeight=u.getBoundingClientRect().height)}printLabels({i:e,j:t,values:n,ttItems:r,shared:i,e:a}){let o=this.w,{xVal:s,zVal:c,xAxisTTVal:u}=n,d=o.seriesData.series.length,f=t!==null&&o.config.plotOptions.bar.distributed?o.globals.colors[t]:o.globals.colors[e];for(let n=0;n<d;n++){let p=o.config.tooltip.inverseOrder?d-1-n:n,m=this.computeSeriesRow({i:e,j:t,t:n,tIndex:p,shared:i,e:a,basePColor:f});this.DOMHandling({i:e,t:p,j:t,ttItems:r,values:{val:m.val,goalVals:m.goalVals,xVal:s,xAxisTTVal:u,zVal:c},seriesName:m.seriesName,shared:i,pColor:m.pColor})}}computeSeriesRow({i:e,j:t,tIndex:n,shared:r,e:i,basePColor:a}){let o=this.w,u=this.getFormatters(e),d=a,f,p=[],m=o.config.chart.type===`treemap`?u.yLbTitleFormatter(String(o.config.series[e].data[t].x),{series:o.seriesData.series,seriesIndex:e,dataPointIndex:t,w:o}):this.getSeriesName({fn:u.yLbTitleFormatter,index:e,seriesIndex:e,j:t});return o.globals.axisCharts&&(r?(u=this.getFormatters(n),m=this.getSeriesName({fn:u.yLbTitleFormatter,index:n,seriesIndex:e,j:t}),d=o.globals.colors[n],f=this.formatYValue(u,n,t),p=this.formatGoalVals(u,n,t)):(d=this.resolvePatternColor(i,d),f=this.formatYValue(u,e,t),p=this.formatGoalVals(u,e,t))),t===null&&(f=u.yLbFormatter(o.seriesData.series[e],c(s({},o),{seriesIndex:e,dataPointIndex:e}))),{seriesName:m,val:f,goalVals:p,pColor:d}}formatYValue(e,t,n){var r,i,a,o;let s=this.w,c=s.waterfallData&&s.waterfallData.values;return c&&c[t]&&c[t][n]!=null?e.yLbFormatter(c[t][n],{series:c,seriesIndex:t,dataPointIndex:n,w:s}):s.axisFlags.isRangeData?e.yLbFormatter((i=(r=s.rangeData.seriesRangeStart)==null?void 0:r[t])==null?void 0:i[n],{series:s.rangeData.seriesRangeStart,seriesIndex:t,dataPointIndex:n,w:s})+` - `+e.yLbFormatter((o=(a=s.rangeData.seriesRangeEnd)==null?void 0:a[t])==null?void 0:o[n],{series:s.rangeData.seriesRangeEnd,seriesIndex:t,dataPointIndex:n,w:s}):e.yLbFormatter(s.seriesData.series[t][n],{series:s.seriesData.series,seriesIndex:t,dataPointIndex:n,w:s})}formatGoalVals(e,t,n){var r;let i=this.w,a=(r=i.seriesData.seriesGoals[t])==null?void 0:r[n];return Array.isArray(a)?a.map(r=>({attrs:r,val:e.yLbFormatter(r.value,{seriesIndex:t,dataPointIndex:n,w:i})})):[]}resolvePatternColor(e,t){var n,r,i,a;let o=this.w,s=(r=(n=Utils2.hoverTarget(e))==null?void 0:n.getAttribute)==null?void 0:r.call(n,`fill`);if(!s)return t;if(s.indexOf(`url`)===-1)return s;if(s.indexOf(`Pattern`)===-1)return t;let c=o.dom.baseEl.querySelector(s.substr(4).slice(0,-1));return(a=(i=c==null?void 0:c.childNodes[0])==null?void 0:i.getAttribute(`stroke`))==null?t:a}getFormatters(e){let t=this.w,n=t.formatters.yLabelFormatters[e],r;return t.formatters.ttVal===void 0?r=t.config.tooltip.y.title.formatter:Array.isArray(t.formatters.ttVal)?(n=t.formatters.ttVal[e]&&t.formatters.ttVal[e].formatter,r=t.formatters.ttVal[e]&&t.formatters.ttVal[e].title&&t.formatters.ttVal[e].title.formatter):(n=t.formatters.ttVal.formatter,typeof t.formatters.ttVal.title.formatter==`function`&&(r=t.formatters.ttVal.title.formatter)),typeof n!=`function`&&(n=t.formatters.yLabelFormatters[0]?t.formatters.yLabelFormatters[0]:function(e){return e}),typeof r!=`function`&&(r=function(e){return e?e+`: `:``}),{yLbFormatter:n,yLbTitleFormatter:r}}getSeriesName({fn:e,index:t,seriesIndex:n,j:r}){let i=this.w;return e(String(i.seriesData.seriesNames[t]),{series:i.seriesData.series,seriesIndex:n,dataPointIndex:r,w:i})}DOMHandling({t:e,j:t,ttItems:n,values:r,seriesName:i,shared:a,pColor:o}){let s=this.w,c=this.ttCtx,{val:u,goalVals:d,xVal:f,xAxisTTVal:p,zVal:m}=r;if(!n||!n[e])return;let h=null;h=n[e].children,s.config.tooltip.fillSeriesColor&&(n[e].style.backgroundColor=o,h[0].style.display=`none`),c.showTooltipTitle&&(c.tooltipTitle===null&&(c.tooltipTitle=s.dom.baseEl.querySelector(`.apexcharts-tooltip-title`)),c.tooltipTitle&&(c.tooltipTitle.innerHTML=f)),c.isXAxisTooltipEnabled&&c.xaxisTooltipText&&(c.xaxisTooltipText.innerHTML=p===``?f:p);let g=n[e].querySelector(`.apexcharts-tooltip-text-y-label`);g&&(g.innerHTML=i||``);let _=n[e].querySelector(`.apexcharts-tooltip-text-y-value`);_&&(_.innerHTML=u===void 0?``:u),h[0]&&h[0].classList.contains(`apexcharts-tooltip-marker`)&&(s.config.tooltip.marker.fillColors&&Array.isArray(s.config.tooltip.marker.fillColors)&&(o=s.config.tooltip.marker.fillColors[e]),s.config.tooltip.fillSeriesColor?h[0].style.backgroundColor=o:h[0].style.color=o),s.config.tooltip.marker.show||(h[0].style.display=`none`);let v=n[e].querySelector(`.apexcharts-tooltip-text-goals-label`),y=n[e].querySelector(`.apexcharts-tooltip-text-goals-value`);if(d.length&&s.seriesData.seriesGoals[e]){let n=()=>{let e=`<div>`,t=`<div>`;d.forEach(n=>{e+=` <div style="display: flex"><span class="apexcharts-tooltip-marker" style="background-color: ${n.attrs.strokeColor}; height: 3px; border-radius: 0; top: 5px;"></span> ${n.attrs.name}</div>`,t+=`<div>${n.val}</div>`}),v.innerHTML=e+`</div>`,y.innerHTML=t+`</div>`};a?s.seriesData.seriesGoals[e][t]&&Array.isArray(s.seriesData.seriesGoals[e][t])?n():(v.innerHTML=``,y.innerHTML=``):n()}else v.innerHTML=``,y.innerHTML=``;if(m!==null){let t=n[e].querySelector(`.apexcharts-tooltip-text-z-label`);t.innerHTML=s.config.tooltip.z.title;let r=n[e].querySelector(`.apexcharts-tooltip-text-z-value`);r.innerHTML=m===void 0?``:m}if(a&&h[0]){if(s.config.tooltip.hideEmptySeries){let t=n[e].querySelector(`.apexcharts-tooltip-marker`),r=n[e].querySelector(`.apexcharts-tooltip-text`);parseFloat(u)==0?(t.style.display=`none`,r.style.display=`none`):(t.style.display=`block`,r.style.display=`block`)}u==null||s.globals.ancillaryCollapsedSeriesIndices.indexOf(e)>-1||s.globals.collapsedSeriesIndices.indexOf(e)>-1||Array.isArray(c.tConfig.enabledOnSeries)&&c.tConfig.enabledOnSeries.indexOf(e)===-1?h[0].parentNode.style.display=`none`:h[0].parentNode.style.display=s.config.tooltip.items.display}else Array.isArray(c.tConfig.enabledOnSeries)&&c.tConfig.enabledOnSeries.indexOf(e)===-1&&(h[0].parentNode.style.display=`none`)}toggleActiveInactiveSeries(e,t){let n=this.w;if(e)this.tooltipUtil.toggleAllTooltipSeriesGroups(`enable`);else{this.tooltipUtil.toggleAllTooltipSeriesGroups(`disable`);let e=n.dom.baseEl.querySelector(`.apexcharts-tooltip-series-group-${t}`);if(e){let t=e;t.classList.add(`apexcharts-active`),t.style.display=n.config.tooltip.items.display}}}getValuesToPrint({i:e,j:t}){var n,r,i,a,o,s,c,u;let d=this.w,f=d.seriesData.seriesX.map(e=>e.length>0?e:[]),p=``,m=``,h=null,g=null,_={series:d.seriesData.series,seriesIndex:e,dataPointIndex:t,w:d},v=d.formatters.ttZFormatter;t===null?g=d.seriesData.series[e]:d.axisFlags.isXNumeric&&d.config.chart.type!==`treemap`?(p=f[e][t],f[e].length===0&&(p=f[this.tooltipUtil.getFirstActiveXArray(f)][t])):p=new Data(this.w).isFormatXY()?d.config.series[e].data[t]===void 0?``:d.config.series[e].data[t].x:d.labelData.labels[t]===void 0?``:d.labelData.labels[t];let y=p;return p=d.axisFlags.isXNumeric&&d.config.xaxis.type===`datetime`?new Formatters(this.w).xLabelFormat(d.formatters.ttKeyFormatter,y,y,{i:void 0,dateFormatter:new DateTime(this.w).formatDate,w:this.w}):d.globals.isBarHorizontal?d.formatters.yLabelFormatters[0](y,_):(i=(r=(n=d.formatters).xLabelFormatter)==null?void 0:r.call(n,y,_))==null?y:i,d.config.tooltip.x.formatter!==void 0&&(p=(s=(o=(a=d.formatters).ttKeyFormatter)==null?void 0:o.call(a,y,_))==null?y:s),d.seriesData.seriesZ.length>0&&d.seriesData.seriesZ[e].length>0&&(h=v==null?void 0:v(d.seriesData.seriesZ[e][t],d)),m=typeof d.config.xaxis.tooltip.formatter==`function`?(u=(c=d.formatters).xaxisTooltipFormatter)==null?void 0:u.call(c,y,_):p,{val:Array.isArray(g)?g.join(` `):g,xVal:Array.isArray(p)?p.join(` `):p,xAxisTTVal:Array.isArray(m)?m.join(` `):m,zVal:h}}handleCustomTooltip({i:e,j:t,y1:n,y2:r,w:i}){let a=this.ttCtx.getElTooltip(),o=i.config.tooltip.custom;if(Array.isArray(o)&&(o=o[e]),typeof o!=`function`)return;let s=o({series:i.seriesData.series,seriesIndex:e,dataPointIndex:t,y1:n,y2:r,w:i});if(a){let e=a.querySelector(`.apexcharts-tooltip-arrow`);typeof s==`string`||typeof s==`number`?a.innerHTML=String(s):s!=null&&(s instanceof Element||typeof s.nodeName==`string`)&&(a.innerHTML=``,a.appendChild(s.cloneNode(!0))),e&&a.appendChild(e)}}}const ln=7,un=0;class Position{constructor(e){this.ttCtx=e,this.w=e.w}moveXCrosshairs(e,t=null){let n=this.ttCtx,r=this.w,i=n.getElXCrosshairs(),a=e-n.xcrosshairsWidth/2,o=r.labelData.labels.slice().length;if(t!==null&&(a=r.layout.gridWidth/o*t),i!==null&&!r.globals.isBarHorizontal&&(i.setAttribute(`x`,String(a)),i.setAttribute(`x1`,String(a)),i.setAttribute(`x2`,String(a)),i.setAttribute(`y2`,String(r.layout.gridHeight)),i.classList.add(`apexcharts-active`)),a<0&&(a=0),a>r.layout.gridWidth&&(a=r.layout.gridWidth),n.isXAxisTooltipEnabled){let e=a;(r.config.xaxis.crosshairs.width===`tickWidth`||r.config.xaxis.crosshairs.width===`barWidth`)&&(e=a+n.xcrosshairsWidth/2),this.moveXAxisTooltip(e)}}moveYCrosshairs(e){let t=this.ttCtx;t.ycrosshairs!==null&&Graphics.setAttrs(t.ycrosshairs,{y1:e,y2:e}),t.ycrosshairsHidden!==null&&Graphics.setAttrs(t.ycrosshairsHidden,{y1:e,y2:e})}moveXAxisTooltip(e){var t,n;let r=this.w,i=this.ttCtx;if(i.xaxisTooltip!==null&&i.xcrosshairsWidth!==0){i.xaxisTooltip.classList.add(`apexcharts-active`);let a=i.xaxisOffY+r.config.xaxis.tooltip.offsetY+r.layout.translateY+5+r.config.xaxis.offsetY,o=i.xaxisTooltip.getBoundingClientRect().width;if(e-=o/2,!isNaN(e)){e+=r.layout.translateX;let o=new Graphics(this.w).getTextRects((n=(t=i.xaxisTooltipText)==null?void 0:t.innerHTML)==null?``:n,r.config.xaxis.labels.style.fontSize);i.xaxisTooltipText&&(i.xaxisTooltipText.style.minWidth=o.width+`px`),i.xaxisTooltip.style.left=e+`px`,i.xaxisTooltip.style.top=a+`px`}}}moveYAxisTooltip(e){var t,n;let r=this.w,i=this.ttCtx;i.yaxisTTEls===null&&(i.yaxisTTEls=[...r.dom.baseEl.querySelectorAll(`.apexcharts-yaxistooltip`)]);let a=parseInt((n=(t=i.ycrosshairsHidden)==null?void 0:t.getAttribute(`y1`))==null?`0`:n,10),o=r.layout.translateY+a;if(i.yaxisTTEls){let t=i.yaxisTTEls[e].getBoundingClientRect(),n=t.height,a,s=r.dom.baseEl.querySelector(`.apexcharts-yaxis[rel='${e}'] .apexcharts-yaxis-texts-g`),c=r.dom.elWrap.getBoundingClientRect();if(s){let e=s.getBoundingClientRect();e.width>0&&(a=e.left+e.width/2-c.left-t.width/2)}if(a==null){let n=4;a=r.config.yaxis[e].opposite?r.globals.translateYAxisX[e]+4:r.globals.translateYAxisX[e]-t.width-4}o-=n/2,r.globals.ignoreYAxisIndexes.indexOf(e)===-1&&o>0&&o<r.layout.gridHeight?(i.yaxisTTEls[e].classList.add(`apexcharts-active`),i.yaxisTTEls[e].style.top=o+`px`,i.yaxisTTEls[e].style.left=a+r.config.yaxis[e].tooltip.offsetX+`px`):i.yaxisTTEls[e].classList.remove(`apexcharts-active`)}}moveTooltip(e,t,n=null){let r=this.ttCtx.getElTooltip();if(!r)return;let i=this.computeTooltipPosition(e,t,n);i!==null&&this.applyTooltipPosition(r,i)}computeTooltipPosition(e,t,n=null){var r,i,a,o,s,c,u,d,f;let p=this.w,m=this.ttCtx,h=m.tooltipRect,g=!!p.config.tooltip.arrow,_=n===null?1:parseFloat(String(n)),v=h.ttHeight||0,y=h.ttWidth||0,b=parseFloat(String(e)),x=parseFloat(String(t));if(isNaN(b)||isNaN(x))return null;let S=_+(g?7:0)+0,C=b+S,w=x+p.layout.translateY,T=g?w-v/2+_/2:x+_/2,E=`right`;if(C>p.layout.gridWidth/2&&(C=b-y-S,E=`left`),C>p.layout.gridWidth-y-10&&(C=E===`left`?Math.min(p.layout.gridWidth-y,C):p.layout.gridWidth-y),C<-20&&(C=-20),p.config.tooltip.followCursor){let e=m.getElGrid();if(!e)return null;let t=e.getBoundingClientRect();C=((r=m.clientX)==null?m.e.clientX:r)-t.left,C>p.layout.gridWidth/2?(C-=y,E=`left`):E=`right`,T=((i=m.clientY)==null?m.e.clientY:i)+p.layout.translateY-t.top,T>p.layout.gridHeight/2&&(T-=v)}else if(!p.globals.isBarHorizontal)if(g){let e=p.layout.translateY,t=p.layout.translateY+p.layout.gridHeight;T+v>t&&(T=t-v),T<e&&(T=e)}else v/2+T>p.layout.gridHeight&&(T=p.layout.gridHeight-v+p.layout.translateY);if(isNaN(C))return null;C+=p.layout.translateX;let D=(o=(a=p.config)==null?void 0:a.chart)==null?void 0:o.accessibility;if(D!=null&&D.enabled&&(c=(s=D==null?void 0:D.keyboard)==null?void 0:s.navigation)!=null&&c.enabled&&(f=(d=(u=p.dom)==null?void 0:u.baseEl)==null?void 0:d.querySelector)!=null&&f.call(d,`.apexcharts-keyboard-focused`)){let e=g?w:x,t=(_||1)+12,n=T,r=T+v;!isNaN(e)&&v>0&&n<e+t&&r>e-t&&(T=e-v-t,T<0&&(T=e+t))}let O=null;if(g&&v>0){let e=w-T,t=10,n=v-10;O=Math.max(10,Math.min(n,e))}return{x:C,y:T,placement:E,arrowY:O}}applyTooltipPosition(e,t){if(!e)return;let n=e.dataset.positioned!==`true`;n&&(e.style.transitionProperty=`none`),e.style.left=t.x+`px`,e.style.top=t.y+`px`,t.placement&&(e.dataset.placement=t.placement),t.arrowY!=null&&e.style.setProperty(`--apx-tt-arrow-y`,t.arrowY+`px`),t.arrowX!=null&&e.style.setProperty(`--apx-tt-arrow-x`,t.arrowX+`px`),n&&(e.offsetWidth,e.dataset.positioned=`true`,requestAnimationFrame(()=>{e.style.transitionProperty=``}))}moveMarkers(e,t){var n;let r=this.w,i=this.ttCtx;if(r.globals.markers.size[e]>0&&!r.globals.markers.batched){let a=r.dom.baseEl.querySelectorAll(` .apexcharts-series[data\\:realIndex='${e}'] .apexcharts-marker`);for(let e=0;e<a.length;e++)parseInt((n=a[e].getAttribute(`rel`))==null?`0`:n,10)===t&&(i.marker.resetPointsSize(),i.marker.enlargeCurrentPoint(t,a[e]))}else i.marker.resetPointsSize(),this.moveDynamicPointOnHover(t,e)}moveDynamicPointOnHover(e,t){var n,r,i,a,o;let s=this.w,c=this.ttCtx,u=0,d=0,f=new Graphics(this.w),p=s.globals.pointsArray,m=c.tooltipUtil.getHoverMarkerSize(t),h=s.config.series[t].type;if(h&&(h===`column`||h===`candlestick`||h===`boxPlot`||h===`violin`))return;u=(r=(n=p[t])==null?void 0:n[e])==null?void 0:r[0],d=((a=(i=p[t])==null?void 0:i[e])==null?void 0:a[1])||0;let g=s.dom.baseEl.querySelector(`.apexcharts-series[data\\:realIndex='${t}'] .apexcharts-series-markers path`);if(g&&d<s.layout.gridHeight&&d>0){let e=(o=g.getAttribute(`shape`))==null?`circle`:o,t=f.getMarkerPath(u,d,e,m*1.5);g.setAttribute(`d`,t)}this.moveXCrosshairs(u),c.fixedTooltip||this.moveTooltip(u,d,m)}moveDynamicPointsOnHover(e){var t,n;let r=this.ttCtx,i=r.w,a=0,o=0,s=0,c=i.globals.pointsArray,u=new Series(this.w),d=new Graphics(this.w);s=u.getActiveConfigSeriesIndex(`asc`,[`line`,`area`,`scatter`,`bubble`]);let f=r.tooltipUtil.getHoverMarkerSize(s);if((t=c[s])!=null&&t[e]&&(a=c[s][e][0],o=c[s][e][1]),isNaN(a))return;let p=r.tooltipUtil.getAllMarkers();if(p.length)for(let t=0;t<i.seriesData.series.length;t++){let r=c[t];if(i.globals.comboCharts&&r===void 0&&p.splice(t,0,null),p[t]&&r&&r.length){let r=c[t][e][1],o;p[t].setAttribute(`cx`,a);let s=(n=p[t].getAttribute(`shape`))==null?`circle`:n;if(i.config.chart.type===`rangeArea`&&!i.globals.comboCharts){let n=e+i.seriesData.series[t].length;o=c[t][n][1];let a=Math.abs(r-o)/2;r-=a}if(r!==null&&!isNaN(r)&&r<i.layout.gridHeight+f&&r+f>0){let e=d.getMarkerPath(a,r,s,f);p[t].setAttribute(`d`,e)}else p[t].setAttribute(`d`,``)}}this.moveXCrosshairs(a),r.fixedTooltip||this.moveTooltip(a,o||i.layout.gridHeight,f)}moveStickyTooltipOverBars(e,t){var n,r,i,a,o;let s=this.w,c=this.ttCtx,u=s.globals.columnSeries?s.globals.columnSeries.length:s.seriesData.series.length;s.config.chart.stacked&&(u=s.globals.barGroups.length);let d=u>=2&&u%2==0?Math.floor(u/2):Math.floor(u/2)+1;s.globals.isBarHorizontal&&(d=new Series(this.w).getActiveConfigSeriesIndex(`desc`)+1);let f=s.dom.baseEl.querySelector(`.apexcharts-bar-series .apexcharts-series[rel='${d}'] path[j='${e}'], .apexcharts-candlestick-series .apexcharts-series[rel='${d}'] path[j='${e}'], .apexcharts-boxPlot-series .apexcharts-series[rel='${d}'] path[j='${e}'], .apexcharts-violin-series .apexcharts-series[rel='${d}'] path[j='${e}'], .apexcharts-rangebar-series .apexcharts-series[rel='${d}'] path[j='${e}']`);!f&&typeof t==`number`&&(f=s.dom.baseEl.querySelector(`.apexcharts-bar-series .apexcharts-series[data\\:realIndex='${t}'] path[j='${e}'],
        .apexcharts-candlestick-series .apexcharts-series[data\\:realIndex='${t}'] path[j='${e}'],
        .apexcharts-boxPlot-series .apexcharts-series[data\\:realIndex='${t}'] path[j='${e}'],
        .apexcharts-violin-series .apexcharts-series[data\\:realIndex='${t}'] path[j='${e}'],
        .apexcharts-rangebar-series .apexcharts-series[data\\:realIndex='${t}'] path[j='${e}']`));let p=null,m=s.globals.barCanvasCoords;if(!f&&m&&(p=typeof t==`number`&&((n=m[t])==null?void 0:n[e])||null,!p)){for(let t in m)if((r=m[t])!=null&&r[e]){p=m[t][e];break}}let h=f?parseFloat((i=f.getAttribute(`cx`))==null?`0`:i):p?p.cx:0,g=f?parseFloat((a=f.getAttribute(`cy`))==null?`0`:a):p?p.cy:0,_=f?parseFloat((o=f.getAttribute(`barWidth`))==null?`0`:o):p?p.barWidth:0,v=c.getElGrid();if(!v)return;let y=v.getBoundingClientRect(),b=f&&(f.classList.contains(`apexcharts-candlestick-area`)||f.classList.contains(`apexcharts-boxPlot-area`));if(s.axisFlags.isXNumeric){if(f&&!b){let t=this._datapointCenterXFromBars(e);t==null?h-=u%2==0?0:_/2:h=t}f&&b&&(h-=_/2)}else !s.globals.isBarHorizontal&&!p&&(h=c.xAxisTicksPositions[e-1]+c.dataPointsDividedWidth/2,isNaN(h)&&(h=c.xAxisTicksPositions[e]-c.dataPointsDividedWidth/2));if(s.globals.isBarHorizontal?g-=c.tooltipRect.ttHeight:s.config.tooltip.followCursor?g=c.e.clientY-y.top-c.tooltipRect.ttHeight/2:g+c.tooltipRect.ttHeight+15>s.layout.gridHeight&&(g=s.layout.gridHeight),s.globals.isBarHorizontal||this.moveXCrosshairs(h),!c.fixedTooltip){if(s.globals.isBarHorizontal&&!s.config.tooltip.followCursor&&this.placeHorizontalSharedTooltip(e))return;this.moveTooltip(h,g||s.layout.gridHeight)}}_datapointCenterXFromBars(e){var t,n;let r=this.w,i=r.dom.baseEl.querySelectorAll(`.apexcharts-bar-series path[j='${e}'],.apexcharts-rangebar-series path[j='${e}']`);if(!i.length)return null;let a=1/0,o=-1/0;for(let e of i){let r=e.parentNode;if((n=(t=r==null?void 0:r.classList)==null?void 0:t.contains)!=null&&n.call(t,`apexcharts-series-collapsed`))continue;let i=e.getBoundingClientRect();i.width===0&&i.height===0||(i.left<a&&(a=i.left),i.right>o&&(o=i.right))}return isFinite(a)?AxisMapping.screenXToPlotPx(r,(a+o)/2):null}placeHorizontalSharedTooltip(e){var t,n;let r=this.w,i=this.ttCtx,a=i.getElTooltip();if(!a)return!1;let o=i.getElGrid();if(!o)return!1;let s=o.getBoundingClientRect(),c=r.dom.baseEl.querySelectorAll(`.apexcharts-bar-series path[j='${e}'],.apexcharts-rangebar-series path[j='${e}'],.apexcharts-boxPlot-series path[j='${e}']`);if(!c.length)return!1;let u=1/0,d=-1/0,f=1/0,p=-1/0;for(let e of c){let r=e.parentNode;if((n=(t=r==null?void 0:r.classList)==null?void 0:t.contains)!=null&&n.call(t,`apexcharts-series-collapsed`))continue;let i=e.getBoundingClientRect();i.width===0&&i.height===0||(i.left<u&&(u=i.left),i.right>d&&(d=i.right),i.top<f&&(f=i.top),i.bottom>p&&(p=i.bottom))}if(!isFinite(u))return!1;let m=i.tooltipRect.ttWidth||0,h=i.tooltipRect.ttHeight||0,g=(u+d)/2-s.left+r.layout.translateX,_=f-s.top+r.layout.translateY,v=p-s.top+r.layout.translateY,y=r.layout.translateY,b=r.layout.translateY+r.layout.gridHeight,x=r.layout.translateX,S=r.layout.translateX+r.layout.gridWidth,C=`top`,w=_-h-7;if(w<y){let e=v+7;e+h<=b&&(C=`bottom`,w=e)}let T=g-m/2;T<x&&(T=x),T+m>S&&(T=S-m);let E=Math.max(10,Math.min(m-10,g-T));return this.applyTooltipPosition(a,{x:T,y:w,placement:C,arrowY:null,arrowX:E}),!0}}function dn(e){let t=e=>`<svg viewBox="0 0 12 12" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">${e}</svg>`;switch(e){case`square`:case`rect`:return t(`<rect x="1" y="1" width="10" height="10" rx="1" fill="currentColor"/>`);case`line`:return t(`<rect x="0" y="5" width="12" height="2" rx="1" fill="currentColor"/>`);case`diamond`:return t(`<path d="M6 0.5 L11.5 6 L6 11.5 L0.5 6 Z" fill="currentColor"/>`);case`triangle`:return t(`<path d="M6 1 L11.2 10.5 L0.8 10.5 Z" fill="currentColor"/>`);case`cross`:return t(`<path d="M2 2 L10 10 M10 2 L2 10" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>`);case`plus`:return t(`<path d="M6 1 L6 11 M1 6 L11 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>`);case`star`:return t(`<path d="M6 0.5 L7.5 4.4 L11.5 4.7 L8.4 7.2 L9.5 11.1 L6 8.9 L2.5 11.1 L3.6 7.2 L0.5 4.7 L4.5 4.4 Z" fill="currentColor"/>`);case`sparkle`:return t(`<path d="M6 0.5 L7 5 L11.5 6 L7 7 L6 11.5 L5 7 L0.5 6 L5 5 Z" fill="currentColor"/>`);default:return t(`<circle cx="6" cy="6" r="5" fill="currentColor"/>`)}}class Marker{constructor(e){this.w=e.w,this.ttCtx=e,this.ctx=e.ctx,this.tooltipPosition=new Position(e)}drawDynamicPoints(){let e=this.w,t=new Graphics(this.w),n=new Markers(this.w,this.ctx),r=[...e.dom.baseEl.querySelectorAll(`.apexcharts-series`)];e.config.chart.stacked&&r.sort((e,t)=>parseFloat(e.getAttribute(`data:realIndex`))-parseFloat(t.getAttribute(`data:realIndex`)));for(let i=0;i<r.length;i++){let a=r[i].querySelector(`.apexcharts-series-markers-wrap`);if(a!==null){let r=`apexcharts-marker w${(Math.random()+1).toString(36).substring(4)}`;Markers.markersAreInert(e)&&(r+=` no-pointer-events`);let i=n.getMarkerConfig({cssClass:r,seriesIndex:Number(a.getAttribute(`data:realIndex`))}),o=t.drawMarker(0,0,i);o.node.setAttribute(`default-marker-size`,0);let s=BrowserAPIs.createElementNS(P,`g`);s.classList.add(`apexcharts-series-markers`),s.appendChild(o.node),a.appendChild(s)}}}enlargeCurrentPoint(e,t,n=null,r=null){let i=this.w,a=i.config.markers.hover.size;i.config.chart.type!==`bubble`&&(a=this.newPointSize(e,t));let o=t.getAttribute(`cx`),s=t.getAttribute(`cy`);if(n!==null&&r!==null&&(o=n,s=r),this.tooltipPosition.moveXCrosshairs(o),!this.fixedTooltip){if(i.config.chart.type===`radar`){let e=this.ttCtx.getElGrid();if(!e)return;let t=e.getBoundingClientRect();o=this.ttCtx.e.clientX-t.left}this.tooltipPosition.moveTooltip(o,s,a)}}enlargePoints(e){var t,n;let r=this.w,i=this,a=this.ttCtx,o=e,s=r.dom.baseEl.querySelectorAll(`.apexcharts-series:not(.apexcharts-series-collapsed) .apexcharts-marker`),c=r.config.markers.hover.size;for(let e=0;e<s.length;e++){let u=s[e].getAttribute(`rel`),d=s[e].getAttribute(`index`);if(c===void 0&&(c=r.globals.markers.size[d]+r.config.markers.hover.sizeOffset),o===parseInt(u==null?`0`:u,10)){i.newPointSize(o,s[e]);let r=(t=s[e].getAttribute(`cx`))==null?`0`:t,u=(n=s[e].getAttribute(`cy`))==null?`0`:n;i.tooltipPosition.moveXCrosshairs(parseFloat(r)),a.fixedTooltip||i.tooltipPosition.moveTooltip(parseFloat(r),parseFloat(u),c)}else i.oldPointSize(s[e])}}newPointSize(e,t){let n=this.w,r=n.config.markers.hover.size,i=e===0?t.parentNode.firstChild:t.parentNode.lastChild;if(i.getAttribute(`default-marker-size`)!==`0`){let e=parseInt(i.getAttribute(`index`),10);r===void 0&&(r=n.globals.markers.size[e]+n.config.markers.hover.sizeOffset),r<0&&(r=0);let a=this.ttCtx.tooltipUtil.getPathFromPoint(t,r);return t.setAttribute(`d`,a),r}}oldPointSize(e){let t=parseFloat(e.getAttribute(`default-marker-size`)),n=this.ttCtx.tooltipUtil.getPathFromPoint(e,t);e.setAttribute(`d`,n)}resetPointsSize(){var e;let t=this.w.dom.baseEl.querySelectorAll(`.apexcharts-series:not(.apexcharts-series-collapsed) .apexcharts-marker`);for(let n=0;n<t.length;n++){let r=parseFloat((e=t[n].getAttribute(`default-marker-size`))==null?`0`:e);if(_.isNumber(r)&&r>0){let e=this.ttCtx.tooltipUtil.getPathFromPoint(t[n],r);t[n].setAttribute(`d`,e)}else t[n].setAttribute(`d`,`M0,0`)}}}class Intersect{constructor(e){this.w=e.w;let t=this.w;this.ttCtx=e,this.isVerticalGroupedRangeBar=!t.globals.isBarHorizontal&&t.config.chart.type===`rangeBar`&&t.config.plotOptions.bar.rangeBarGroupRows}getAttr(e,t){var n;return parseFloat((n=Utils2.hoverTarget(e).getAttribute(t))==null?``:n)}handleHeatTreeTooltip({e,opt:t,x:n,y:r,type:i}){var a,o,s,c;let u=this.ttCtx,d=this.w,f=d.globals.activeRenderer,p=i===`heatmap`&&f&&f.kind===`canvas`&&typeof f.hitTest==`function`,m=Utils2.hoverTarget(e),h,g,_,v,y,b;if(p){let i=t.elGrid.getBoundingClientRect(),s=(a=t.clientX)==null?e.type===`touchmove`?e.touches[0].clientX:e.clientX:a,c=(o=t.clientY)==null?e.type===`touchmove`?e.touches[0].clientY:e.clientY:o,u=f.hitTest(s-i.left,c-i.top);if(!u)return{x:n,y:r,noHit:!0};h=u.seriesIndex,g=u.dataPointIndex,_=u.x,v=u.y,y=u.width,b=u.height}else if(m.classList.contains(`apexcharts-${i}-rect`))h=this.getAttr(e,`i`),g=this.getAttr(e,`j`),_=this.getAttr(e,`cx`),v=this.getAttr(e,`cy`),y=this.getAttr(e,`width`),b=this.getAttr(e,`height`);else return{x:n,y:r};u.tooltipLabels.drawSeriesTexts({ttItems:t.ttItems,i:h,j:g,shared:!1,e}),d.interact.capturedSeriesIndex=h,d.interact.capturedDataPointIndex=g,u.tooltipPosition.moveXCrosshairs(_+y/2);let x=u.getElTooltip();if(i===`heatmap`&&d.config.tooltip.arrow&&!d.config.tooltip.followCursor&&x){let e=t.elGrid.getBoundingClientRect(),n=d.dom.elWrap.getBoundingClientRect(),r=e.left-n.left,i,a,o,s;if(p)i=_,a=v,o=_+y,s=v+b;else{let t=m.getBoundingClientRect();i=t.left-e.left,a=t.top-e.top,o=t.right-e.left,s=t.bottom-e.top}let c=u.tooltipRect.ttWidth||0,f=u.tooltipRect.ttHeight||0,h=(i+o)/2+r,g=a+d.layout.translateY,S=s+d.layout.translateY,C=d.layout.translateY,w=d.layout.translateY+d.layout.gridHeight,T=r,E=r+d.layout.gridWidth,D=`top`,O=g-f-7;if(O<C){let e=S+7;e+f<=w?(D=`bottom`,O=e):O=C}let k=h-c/2;k<T&&(k=T),k+c>E&&(k=E-c);let j=Math.max(10,Math.min(c-10,h-k));return u.tooltipPosition.applyTooltipPosition(x,{x:k,y:O,placement:D,arrowY:null,arrowX:j}),{x:k,y:O,positioned:!0}}if(n=_+u.tooltipRect.ttWidth/2+y,r=v+u.tooltipRect.ttHeight/2-b/2,n>d.layout.gridWidth/2&&(n=_-u.tooltipRect.ttWidth/2+y),u.w.config.tooltip.followCursor){let e=d.dom.elWrap.getBoundingClientRect();n=((s=d.interact.clientX)==null?0:s)-e.left-(n>d.layout.gridWidth/2?u.tooltipRect.ttWidth:0),r=((c=d.interact.clientY)==null?0:c)-e.top-(r>d.layout.gridHeight/2?u.tooltipRect.ttHeight:0)}let S=u.tooltipRect.ttWidth||0,C=t.elGrid?t.elGrid.getBoundingClientRect():null,w=C?C.left-d.dom.elWrap.getBoundingClientRect().left:d.layout.translateX,T=w+d.layout.gridWidth;return n+S>T&&(n=T-S),n<w&&(n=w),{x:n,y:r}}handleMarkerTooltip({e,opt:t,x:n,y:r}){let i=this.w,a=this.ttCtx,o,s;if(Utils2.hoverTarget(e).classList.contains(`apexcharts-marker`)){let c=parseInt(t.paths.getAttribute(`cx`),10),u=parseInt(t.paths.getAttribute(`cy`),10),d=parseFloat(t.paths.getAttribute(`val`));if(s=parseInt(t.paths.getAttribute(`rel`),10),o=parseInt(t.paths.parentNode.parentNode.parentNode.getAttribute(`rel`),10)-1,a.intersect){let e=_.findAncestor(t.paths,`apexcharts-series`);e&&(o=parseInt(e.getAttribute(`data:realIndex`),10))}a.tooltipLabels.drawSeriesTexts({ttItems:t.ttItems,i:o,j:s,shared:a.showOnIntersect?!1:i.config.tooltip.shared,e}),e.type===`mouseup`&&a.markerClick(e,o,s),i.interact.capturedSeriesIndex=o,i.interact.capturedDataPointIndex=s;let f=!!i.config.tooltip.arrow;if(n=c,f?r=u:(r=u+i.layout.translateY-a.tooltipRect.ttHeight*1.4,d<0&&(r=u)),a.w.config.tooltip.followCursor){let e=a.getElGrid();if(!e)return{x:n,y:r};let t=e.getBoundingClientRect();r=a.e.clientY+i.layout.translateY-t.top}a.marker.enlargeCurrentPoint(s,t.paths,n,r)}return{x:n,y:r}}handleBarTooltip({e,opt:t}){var n,r,i;let a=this.w,o=this.ttCtx,s=o.getElTooltip(),c=0,u=0,d=0,f=0,p,m=this.getBarTooltipXY({e,opt:t});if(m.j===null&&m.barHeight===0&&m.barWidth===0)return;f=m.i;let h=m.j;if(a.interact.capturedSeriesIndex=f,a.interact.capturedDataPointIndex=h===null?a.interact.capturedDataPointIndex:h,a.globals.isBarHorizontal&&o.tooltipUtil.hasBars()||!a.config.tooltip.shared?(u=m.x,d=m.y,p=Array.isArray(a.config.stroke.width)?a.config.stroke.width[f]:a.config.stroke.width,c=u):!a.globals.comboCharts&&!a.config.tooltip.shared&&(c/=2),isNaN(d)&&(d=a.globals.svgHeight-o.tooltipRect.ttHeight),u+o.tooltipRect.ttWidth>a.layout.gridWidth?u-=o.tooltipRect.ttWidth:u<0&&(u=0),!(o.w.config.tooltip.followCursor&&!o.getElGrid())&&(o.tooltip===null&&(o.tooltip=a.dom.baseEl.querySelector(`.apexcharts-tooltip:not(.apexcharts-annotation-tooltip)`)),a.config.tooltip.shared||(a.globals.comboBarCount>0?o.tooltipPosition.moveXCrosshairs(c+p/2):o.tooltipPosition.moveXCrosshairs(c)),!o.fixedTooltip&&(!a.config.tooltip.shared||a.globals.isBarHorizontal&&o.tooltipUtil.hasBars())&&(d=d+a.layout.translateY-o.tooltipRect.ttHeight/2,s))){let e=o.tooltipRect.ttWidth||0,t=o.tooltipRect.ttHeight||0,c=!!a.config.tooltip.arrow,{barAnchorXInGrid:f,barAnchorYInGrid:p,barRectInGrid:h}=m,g=(n=o.getElGrid())==null?void 0:n.getBoundingClientRect(),_=a.dom.elWrap.getBoundingClientRect(),v=g?g.left-_.left:a.layout.translateX,y,b=null,x=null,S=u+v,C=d;if(c&&a.globals.isBarHorizontal&&h!=null){let n=a.layout.translateY,r=a.layout.translateY+a.layout.gridHeight,i=v,o=v+a.layout.gridWidth,s=(h.left+h.right)/2+v,c=h.top+a.layout.translateY,u=h.bottom+a.layout.translateY,d=c-t-7;if(y=`top`,d<n){let e=u+7;e+t<=r&&(y=`bottom`,d=e)}C=d,S=s-e/2,S<i&&(S=i),S+e>o&&(S=o-e),x=Math.max(10,Math.min(e-10,s-S))}else if(c&&f!=null&&p!=null){let n=f+v,o=v+a.layout.gridWidth/2,s=((r=h==null?void 0:h.left)==null?f:r)+v,c=((i=h==null?void 0:h.right)==null?f:i)+v;if(n<o?(y=`right`,S=c+7):(y=`left`,S=s-e-7),h){C=(h.top+h.bottom)/2+a.layout.translateY-t/2;let e=a.layout.translateY,n=a.layout.translateY+a.layout.gridHeight;C<e&&(C=e),C+t>n&&(C=n-t)}if(t>0&&h){let e=(h.top+h.bottom)/2+a.layout.translateY;b=Math.max(10,Math.min(t-10,e-C))}}o.tooltipPosition.applyTooltipPosition(s,{x:S,y:C,placement:y,arrowY:b,arrowX:x})}}getBarTooltipXY({e,opt:t}){let n=this.w,r=null,i=this.ttCtx,a=0,o=0,s=0,c=0,u=0,d=null,f=null,p=null,m=null,h=null,g=Utils2.hoverTarget(e),_=g.classList;if(_.contains(`apexcharts-bar-area`)||_.contains(`apexcharts-candlestick-area`)||_.contains(`apexcharts-boxPlot-area`)||_.contains(`apexcharts-rangebar-area`)){let _=g,v=_.getBoundingClientRect(),y=t.elGrid.getBoundingClientRect(),b=v.height;u=v.height;let x=v.width,S=parseInt(_.getAttribute(`cx`),10),C=parseInt(_.getAttribute(`cy`),10);d=S,f=C,c=parseFloat(_.getAttribute(`barWidth`));let w=v.left-y.left,T=v.top-y.top,E=w+x/2,D=T+b/2;p=E,m=n.globals.isBarHorizontal?D:T,h={left:w,top:T,right:w+x,bottom:T+b};let O=e.type===`touchmove`?e.touches[0].clientX:e.clientX;r=parseInt(_.getAttribute(`j`),10),a=parseInt(_.parentNode.getAttribute(`rel`),10)-1;let k=_.getAttribute(`data-range-y1`),j=_.getAttribute(`data-range-y2`);n.globals.comboCharts&&(a=parseInt(_.parentNode.getAttribute(`data:realIndex`),10));let M=e=>(e=n.axisFlags.isXNumeric?S-x/2:this.isVerticalGroupedRangeBar?S+x/2:S-i.dataPointsDividedWidth+x/2,e),N=()=>C-i.dataPointsDividedHeight+b/2-i.tooltipRect.ttHeight/2;i.tooltipLabels.drawSeriesTexts({ttItems:t.ttItems,i:a,j:r,y1:k?parseInt(k,10):null,y2:j?parseInt(j,10):null,shared:i.showOnIntersect?!1:n.config.tooltip.shared,e}),n.config.tooltip.followCursor?n.globals.isBarHorizontal?(o=O-y.left+15,s=N()):(o=M(o),s=e.clientY-y.top-i.tooltipRect.ttHeight/2-15):n.globals.isBarHorizontal?(o=S,i.xyRatios&&o<i.xyRatios.baseLineInvertedY&&(o=S-i.tooltipRect.ttWidth),s=N()):(o=M(o),s=C)}return{x:o,y:s,barHeight:u,barWidth:c,i:a,j:r,barCx:d,barCy:f,barAnchorXInGrid:p,barAnchorYInGrid:m,barRectInGrid:h}}}class AxesTooltip{constructor(e){this.w=e.w,this.ttCtx=e}drawXaxisTooltip(){let e=this.w,t=this.ttCtx,n=e.config.xaxis.position===`bottom`;t.xaxisOffY=n?e.layout.gridHeight+1:-e.layout.xAxisHeight-e.config.xaxis.axisTicks.height+3;let r=n?`apexcharts-xaxistooltip apexcharts-xaxistooltip-bottom`:`apexcharts-xaxistooltip apexcharts-xaxistooltip-top`,i=e.dom.elWrap;t.isXAxisTooltipEnabled&&e.dom.baseEl.querySelector(`.apexcharts-xaxistooltip`)===null&&(t.xaxisTooltip=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`),t.xaxisTooltip.setAttribute(`class`,r+` apexcharts-theme-`+e.config.tooltip.theme),i.appendChild(t.xaxisTooltip),t.xaxisTooltipText=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`),t.xaxisTooltipText.classList.add(`apexcharts-xaxistooltip-text`),t.xaxisTooltipText.style.fontFamily=e.config.xaxis.tooltip.style.fontFamily||e.config.chart.fontFamily,t.xaxisTooltipText.style.fontSize=e.config.xaxis.tooltip.style.fontSize,t.xaxisTooltip.appendChild(t.xaxisTooltipText))}drawYaxisTooltip(){let e=this.w,t=this.ttCtx;for(let n=0;n<e.config.yaxis.length;n++){let r=e.config.yaxis[n].opposite||e.config.yaxis[n].crosshairs.opposite;t.yaxisOffX=r?e.layout.gridWidth+1:1;let i=r?`apexcharts-yaxistooltip apexcharts-yaxistooltip-${n} apexcharts-yaxistooltip-right`:`apexcharts-yaxistooltip apexcharts-yaxistooltip-${n} apexcharts-yaxistooltip-left`,a=e.dom.elWrap;e.dom.baseEl.querySelector(`.apexcharts-yaxistooltip.apexcharts-yaxistooltip-${n}`)===null&&(t.yaxisTooltip=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`),t.yaxisTooltip.setAttribute(`class`,i+` apexcharts-theme-`+e.config.tooltip.theme),a.appendChild(t.yaxisTooltip),n===0&&(t.yaxisTooltipText=[]),t.yaxisTooltipText[n]=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`),t.yaxisTooltipText[n].classList.add(`apexcharts-yaxistooltip-text`),t.yaxisTooltip.appendChild(t.yaxisTooltipText[n]))}}setXCrosshairWidth(){var e,t;let n=this.w,r=this.ttCtx,i=r.getElXCrosshairs();if(r.xcrosshairsWidth=parseInt(n.config.xaxis.crosshairs.width,10),n.globals.comboCharts){let e=n.dom.baseEl.querySelector(`.apexcharts-bar-area`);if(e!==null&&n.config.xaxis.crosshairs.width===`barWidth`)r.xcrosshairsWidth=parseFloat((t=e.getAttribute(`barWidth`))==null?`0`:t);else if(n.config.xaxis.crosshairs.width===`tickWidth`){let e=n.labelData.labels.length;r.xcrosshairsWidth=n.layout.gridWidth/e}}else if(n.config.xaxis.crosshairs.width===`tickWidth`){let e=n.labelData.labels.length;r.xcrosshairsWidth=n.layout.gridWidth/e}else if(n.config.xaxis.crosshairs.width===`barWidth`){let t=n.dom.baseEl.querySelector(`.apexcharts-bar-area`);t===null?r.xcrosshairsWidth=1:r.xcrosshairsWidth=parseFloat((e=t.getAttribute(`barWidth`))==null?`0`:e)}n.globals.isBarHorizontal&&(r.xcrosshairsWidth=0),i!==null&&r.xcrosshairsWidth>0&&i.setAttribute(`width`,String(r.xcrosshairsWidth))}handleYCrosshair(){let e=this.w,t=this.ttCtx;t.ycrosshairs=e.dom.baseEl.querySelector(`.apexcharts-ycrosshairs`),t.ycrosshairsHidden=e.dom.baseEl.querySelector(`.apexcharts-ycrosshairs-hidden`)}drawYaxisTooltipText(e,t,n){let r=this.ttCtx,i=this.w,a=i.globals,o=a.seriesYAxisMap[e];if(r.yaxisTooltips[e]&&o.length>0){let s=i.formatters.yLabelFormatters[e],c=r.getElGrid();if(!c)return;let u=c.getBoundingClientRect(),d=o[0],f=0;n.yRatio.length>1&&(f=d);let p=(t-u.top)*n.yRatio[f],m=a.maxYArr[d]-a.minYArr[d],h=a.minYArr[d]+(m-p);i.config.yaxis[e].reversed&&(h=a.maxYArr[d]-(m-p)),r.tooltipPosition.moveYCrosshairs(t-u.top),r.yaxisTooltipText[e].innerHTML=s(h),r.tooltipPosition.moveYAxisTooltip(e)}}}class Tooltip{constructor(e,t){this.w=e,this.ctx=t,this.tConfig=e.config.tooltip,this.tooltipUtil=new Utils2(this),this.tooltipLabels=new Labels(this),this.tooltipPosition=new Position(this),this.marker=new Marker(this),this.intersect=new Intersect(this),this.axesTooltip=new AxesTooltip(this),this.showOnIntersect=this.tConfig.intersect,this.showTooltipTitle=this.tConfig.x.show,this.fixedTooltip=this.tConfig.fixed.enabled,this.xaxisTooltip=null,this.xaxisTooltipText=null,this.yaxisTooltip=null,this.yaxisTooltipText=null,this.yaxisTTEls=null,this.xaxisOffY=0,this.yaxisOffX=0,this.xcrosshairsWidth=0,this.ycrosshairs=null,this.ycrosshairsHidden=null,this.tooltip=null,this.e=null,this.isBarShared=!e.globals.isBarHorizontal&&this.tConfig.shared,this.lastHoverTime=Date.now(),this.dimensionUpdateScheduled=!1,this.xyRatios=null,this.isXAxisTooltipEnabled=!1,this.yaxisTooltips=[],this.allTooltipSeriesGroups=[],this.xAxisTicksPositions=null,this.dataPointsDividedHeight=0,this.dataPointsDividedWidth=0,this.tooltipTitle=null,this.legendLabels=null,this.ttItems=null,this.seriesBound=null,this.seriesHoverTimeout=void 0,this.clientX=0,this.clientY=0,this.barSeriesHeight=0,this.tooltipRect={x:0,y:0,ttWidth:0,ttHeight:0}}setupDimensionCache(){let e=this.w,t=this.getElTooltip();t&&(this.updateDimensionCache(),typeof ResizeObserver<`u`&&!e.globals.resizeObserver&&(e.globals.resizeObserver=new ResizeObserver(()=>{this.dimensionUpdateScheduled||(this.dimensionUpdateScheduled=!0,requestAnimationFrame(()=>{this.updateDimensionCache(),this.dimensionUpdateScheduled=!1}))}),e.globals.resizeObserver.observe(t)))}updateDimensionCache(){let e=this.w,t=this.getElTooltip();if(!t)return;let n=t.getBoundingClientRect();e.globals.dimensionCache.tooltip={width:n.width,height:n.height,lastUpdate:Date.now()}}getCachedDimensions(){let e=this.w;if(e.globals.dimensionCache.tooltip){let t=e.globals.dimensionCache.tooltip;if(Date.now()-t.lastUpdate<1e3)return{ttWidth:t.width,ttHeight:t.height}}this.updateDimensionCache();let t=e.globals.dimensionCache.tooltip;return t?{ttWidth:t.width,ttHeight:t.height}:{ttWidth:0,ttHeight:0}}getElTooltip(e){return e||(e=this),e.w.dom.baseEl?e.w.dom.baseEl.querySelector(`.apexcharts-tooltip:not(.apexcharts-annotation-tooltip)`):null}getElXCrosshairs(){return this.w.dom.baseEl.querySelector(`.apexcharts-xcrosshairs`)}getElGrid(){return this.w.dom.baseEl.querySelector(`.apexcharts-grid`)}drawTooltip(e){let t=this.w;this.xyRatios=e,this.isXAxisTooltipEnabled=t.config.xaxis.tooltip.enabled&&t.globals.axisCharts,this.yaxisTooltips=t.config.yaxis.map(e=>!!(e.show&&e.tooltip.enabled&&t.globals.axisCharts)),this.allTooltipSeriesGroups=[],t.globals.axisCharts||(this.showTooltipTitle=!1);let n=this.getElTooltip();n!=null&&n.parentNode&&n.parentNode.removeChild(n),this.tooltipTitle=null;let r=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`);r.classList.add(`apexcharts-tooltip`),t.config.tooltip.cssClass&&r.classList.add(t.config.tooltip.cssClass),r.classList.add(`apexcharts-theme-${this.tConfig.theme||`light`}`),this.tConfig.fillSeriesColor&&r.classList.add(`apexcharts-tooltip-fill-series`),this.tConfig.compact&&(r.classList.add(`apexcharts-tooltip-compact`),t.config.series.length===1&&r.classList.add(`apexcharts-tooltip-value-only`)),this.tConfig.style&&this.tConfig.style.background&&r.style.setProperty(`--apx-tt-bg`,this.tConfig.style.background);let i=this.tConfig.shared&&t.config.series.length>1&&!t.globals.isBarHorizontal&&t.config.chart.type!==`heatmap`;if(this.tConfig.arrow&&!this.tConfig.followCursor&&!this.tConfig.fixed.enabled&&!i&&!this.tConfig.fillSeriesColor&&t.globals.axisCharts){let e=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`);e.classList.add(`apexcharts-tooltip-arrow`),r.appendChild(e)}if(t.config.chart.accessibility.enabled&&t.config.chart.accessibility.announcements.enabled&&(r.setAttribute(`role`,`tooltip`),r.setAttribute(`aria-live`,`polite`),r.setAttribute(`aria-atomic`,`true`),r.setAttribute(`aria-hidden`,`true`)),t.dom.elWrap.appendChild(r),t.globals.axisCharts){this.axesTooltip.drawXaxisTooltip(),this.axesTooltip.drawYaxisTooltip(),this.axesTooltip.setXCrosshairWidth(),this.axesTooltip.handleYCrosshair();let e=new XAxis(this.w,this.ctx,void 0);this.xAxisTicksPositions=e.getXAxisTicksPositions()}if((t.globals.comboCharts||this.tConfig.intersect||t.config.chart.type===`rangeBar`)&&!this.tConfig.shared&&(this.showOnIntersect=!0),(t.config.markers.size===0||t.globals.markers.largestSize===0||t.globals.markers.batched)&&this.marker.drawDynamicPoints(),t.globals.collapsedSeries.length===t.seriesData.series.length)return;this.dataPointsDividedHeight=t.layout.gridHeight/t.globals.dataPoints,this.dataPointsDividedWidth=t.layout.gridWidth/t.globals.dataPoints,this.showTooltipTitle&&(this.tooltipTitle=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`),this.tooltipTitle.classList.add(`apexcharts-tooltip-title`),this.tooltipTitle.style.fontFamily=this.tConfig.style.fontFamily||t.config.chart.fontFamily,this.tooltipTitle.style.fontSize=this.tConfig.style.fontSize,r.appendChild(this.tooltipTitle));let a=t.seriesData.series.length;(t.globals.xyCharts||t.globals.comboCharts)&&this.tConfig.shared&&(a=this.showOnIntersect?1:t.seriesData.series.length),this.legendLabels=t.dom.baseEl.querySelectorAll(`.apexcharts-legend-text`),this.ttItems=this.createTTElements(a),this.addSVGEvents(),this.setupDimensionCache()}createTTElements(e){let t=this.w,n=[],r=this.getElTooltip();if(!r)return n;for(let i=0;i<e;i++){let a=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`);a.classList.add(`apexcharts-tooltip-series-group`,`apexcharts-tooltip-series-group-${i}`),a.style.order=String(t.config.tooltip.inverseOrder?e-i:i+1);let o=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`span`);o.classList.add(`apexcharts-tooltip-marker`),t.config.tooltip.fillSeriesColor?o.style.backgroundColor=t.globals.colors[i]:o.style.color=t.globals.colors[i];let s=t.config.markers.shape,c=s;Array.isArray(s)&&(c=s[i]),o.setAttribute(`shape`,c),o.innerHTML=dn(c),a.appendChild(o);let u=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`);u.classList.add(`apexcharts-tooltip-text`),u.style.fontFamily=this.tConfig.style.fontFamily||t.config.chart.fontFamily,u.style.fontSize=this.tConfig.style.fontSize,[`y`,`goals`,`z`].forEach(e=>{let t=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`div`);t.classList.add(`apexcharts-tooltip-${e}-group`);let n=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`span`);n.classList.add(`apexcharts-tooltip-text-${e}-label`),t.appendChild(n);let r=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`span`);r.classList.add(`apexcharts-tooltip-text-${e}-value`),t.appendChild(r),u.appendChild(t)}),a.appendChild(u),r.appendChild(a),n.push(a)}return n}addSVGEvents(){let e=this.w,t=e.config.chart.type,n=this.getElTooltip();if(!n)return;let r=t===`bar`||t===`candlestick`||t===`boxPlot`||t===`violin`||t===`rangeBar`,i=t===`area`||t===`line`||t===`scatter`||t===`bubble`||t===`radar`,a=i&&!e.globals.xyCharts,o=e.dom.Paper.node,s=this.getElGrid();s&&(this.seriesBound=s.getBoundingClientRect());let c=[],u=[],d={hoverArea:o,elGrid:s,tooltipEl:n,tooltipY:c,tooltipX:u,ttItems:this.ttItems},f;if(e.globals.axisCharts&&(i?f=e.dom.baseEl.querySelectorAll(`.apexcharts-series[data\\:longestSeries='true'] .apexcharts-marker`):r?f=e.dom.baseEl.querySelectorAll(`.apexcharts-series .apexcharts-bar-area, .apexcharts-series .apexcharts-candlestick-area, .apexcharts-series .apexcharts-boxPlot-area, .apexcharts-series .apexcharts-violin-area, .apexcharts-series .apexcharts-rangebar-area`):(t===`heatmap`||t===`treemap`)&&(f=e.dom.baseEl.querySelectorAll(`.apexcharts-series .apexcharts-heatmap, .apexcharts-series .apexcharts-treemap`)),f&&f.length))for(let e=0;e<f.length;e++)c.push(f[e].getAttribute(`cy`)),u.push(f[e].getAttribute(`cx`));if(e.globals.xyCharts&&!this.showOnIntersect||e.globals.comboCharts&&!this.showOnIntersect||r&&this.tooltipUtil.hasBars()&&this.tConfig.shared)this.addPathsEventListeners([o],d);else if(r&&!e.globals.comboCharts||i&&this.showOnIntersect||a)this.addDatapointEventsListeners(d);else if(t===`heatmap`&&e.globals.activeRenderer&&e.globals.activeRenderer.kind===`canvas`)this.addPathsEventListeners([o],d);else if(!e.globals.axisCharts||t===`heatmap`||t===`treemap`){let t=e.dom.baseEl.querySelectorAll(`.apexcharts-series`);this.addPathsEventListeners(t,d)}if(this.showOnIntersect){let t=e.dom.baseEl.querySelectorAll(`.apexcharts-line-series .apexcharts-marker, .apexcharts-area-series .apexcharts-marker`);t.length>0&&this.addPathsEventListeners(t,d),this.tooltipUtil.hasBars()&&!this.tConfig.shared&&this.addDatapointEventsListeners(d)}}drawFixedTooltipRect(){let e=this.w,t=this.getElTooltip();if(!t)return{x:0,y:0,ttWidth:0,ttHeight:0};let n=t.getBoundingClientRect(),r=n.width+10,i=n.height+10,a=this.tConfig.fixed.offsetX,o=this.tConfig.fixed.offsetY,s=this.tConfig.fixed.position.toLowerCase();return s.indexOf(`right`)>-1&&(a=a+e.globals.svgWidth-r+10),s.indexOf(`bottom`)>-1&&(o=o+e.globals.svgHeight-i-10),this.tooltipPosition.applyTooltipPosition(t,{x:a,y:o}),{x:a,y:o,ttWidth:r,ttHeight:i}}addDatapointEventsListeners(e){let t=this.w.dom.baseEl.querySelectorAll(`.apexcharts-series-markers .apexcharts-marker, .apexcharts-bar-area, .apexcharts-candlestick-area, .apexcharts-boxPlot-area, .apexcharts-rangebar-area`);this.addPathsEventListeners(t,e)}addPathsEventListeners(e,t){let n=this;for(let r=0;r<e.length;r++){let i={paths:e[r],tooltipEl:t.tooltipEl,tooltipY:t.tooltipY,tooltipX:t.tooltipX,elGrid:t.elGrid,hoverArea:t.hoverArea,ttItems:t.ttItems};[`mousemove`,`mouseup`,`touchmove`,`mouseout`,`touchend`].map(t=>e[r].addEventListener(t,n.onSeriesHover.bind(n,i),{capture:!1,passive:!0}))}}onSeriesHover(e,t){Utils2.hoverTarget(t);let n=20,r=Date.now()-this.lastHoverTime;r>=20?this.seriesHover(e,t):(clearTimeout(this.seriesHoverTimeout),this.seriesHoverTimeout=setTimeout(()=>{this.seriesHover(e,t)},20-r))}seriesHover(e,t){var n;if(this.w.globals.isDestroyed)return;this.lastHoverTime=Date.now();let r=[],i=this.w,a=e=>{var t,n,r;let i=(r=(n=(t=e==null?void 0:e.w)==null?void 0:t.config)==null?void 0:n.chart)==null?void 0:r.link;return!!(i&&typeof i.dimension==`function`)};if(i.config.chart.group&&!a(this.ctx)&&(r=this.ctx.getSyncedCharts().filter(e=>!a(e))),!(i.globals.axisCharts&&(i.globals.minX===-1/0&&i.globals.maxX===1/0||i.globals.dataPoints===0)))if(r.length){let i=(n=e.elGrid)==null?void 0:n.getBoundingClientRect(),a=t.type===`touchmove`?t.touches[0]:t;r.forEach(n=>{let r=this.getElTooltip(n),o=n.w.globals.tooltip.getElGrid(),s=o==null?void 0:o.getBoundingClientRect(),c=i&&s?s.left+(a.clientX-i.left)/i.width*s.width:a.clientX,u=i&&s?s.top+(a.clientY-i.top)/i.height*s.height:a.clientY,d={paths:e.paths,tooltipEl:r,tooltipY:e.tooltipY,tooltipX:e.tooltipX,elGrid:o||e.elGrid,hoverArea:e.hoverArea,ttItems:n.w.globals.tooltip.ttItems,clientX:c,clientY:u};n.w.globals.minX===this.w.globals.minX&&n.w.globals.maxX===this.w.globals.maxX&&n.w.globals.tooltip.seriesHoverByContext({chartCtx:n,ttCtx:n.w.globals.tooltip,opt:d,e:t})})}else this.seriesHoverByContext({chartCtx:this.ctx,ttCtx:this.w.globals.tooltip,opt:e,e:t})}seriesHoverByContext({chartCtx:e,ttCtx:t,opt:n,e:r}){var i;let a=e.w;if(!this.getElTooltip(e))return;let o=t.getCachedDimensions();t.tooltipRect={x:0,y:0,ttWidth:o.ttWidth,ttHeight:o.ttHeight},t.e=r,t.tooltipUtil.hasBars()&&!a.globals.comboCharts&&!t.isBarShared&&this.tConfig.onDatasetHover.highlightDataSeries&&new Series(e.w).toggleSeriesOnHover(r,(i=Utils2.hoverTarget(r))==null?void 0:i.parentNode),a.globals.axisCharts?t.axisChartsTooltips({e:r,opt:n,tooltipRect:t.tooltipRect}):t.nonAxisChartsTooltips({e:r,opt:n,tooltipRect:t.tooltipRect}),t.fixedTooltip&&t.drawFixedTooltipRect()}axisChartsTooltips({e,opt:t}){var n,r,i;let a=this.w,o,s;if(!t.elGrid)return;let c=t.elGrid.getBoundingClientRect(),u=(n=t.clientX)==null?e.type===`touchmove`?e.touches[0].clientX:e.clientX:n,d=(r=t.clientY)==null?e.type===`touchmove`?e.touches[0].clientY:e.clientY:r;if(this.clientY=d,this.clientX=u,a.interact.capturedSeriesIndex=-1,a.interact.capturedDataPointIndex=-1,d<c.top||d>c.top+c.height){this.handleMouseOut(t);return}if(a.dom.elWrap.querySelector(`.apexcharts-annotation-tooltip.apexcharts-active`)){this.handleMouseOut(t);return}if(Array.isArray(this.tConfig.enabledOnSeries)&&!a.config.tooltip.shared){let e=parseInt(t.paths.getAttribute(`index`),10);if(this.tConfig.enabledOnSeries.indexOf(e)<0){this.handleMouseOut(t);return}}let f=this.getElTooltip();if(!f)return;let p=this.getElXCrosshairs(),m=[`heatmap`,`treemap`].includes(a.config.chart.type),h=[];a.config.chart.group&&!m&&(h=this.ctx.getSyncedCharts());let g=a.globals.xyCharts||a.config.chart.type===`bar`&&!a.globals.isBarHorizontal&&this.tooltipUtil.hasBars()&&this.tConfig.shared||a.globals.comboCharts&&this.tooltipUtil.hasBars();if(e.type===`mousemove`||e.type===`touchmove`||e.type===`mouseup`){if(a.globals.collapsedSeries.length+a.globals.ancillaryCollapsedSeries.length===a.seriesData.series.length)return;p!==null&&p.classList.add(`apexcharts-active`);let n=(i=this.yaxisTooltips)==null?void 0:i.filter(e=>e===!0),r=this.ycrosshairs;if(r!==null&&n!=null&&n.length&&r.classList.add(`apexcharts-active`),!m&&(g&&!this.showOnIntersect||h.length>1))this.handleStickyTooltip(e,u,d,t);else if(a.config.chart.type===`heatmap`||a.config.chart.type===`treemap`){let n=this.intersect.handleHeatTreeTooltip({e,opt:t,x:o,y:s,type:a.config.chart.type});if(n.noHit){this.handleMouseOut(t);return}o=n.x,s=n.y,n.positioned||(f.style.left=o+`px`,f.style.top=s+`px`)}else this.tooltipUtil.hasBars()&&this.intersect.handleBarTooltip({e,opt:t}),this.tooltipUtil.hasMarkers(0)&&this.intersect.handleMarkerTooltip({e,opt:t,x:o,y:s});if(this.yaxisTooltips&&this.yaxisTooltips.length)for(let e=0;e<a.config.yaxis.length;e++)this.axesTooltip.drawYaxisTooltipText(e,d,this.xyRatios);a.dom.baseEl.classList.add(`apexcharts-tooltip-active`),t.tooltipEl.classList.add(`apexcharts-active`),a.config.chart.accessibility.enabled&&a.config.chart.accessibility.announcements.enabled&&t.tooltipEl.removeAttribute(`aria-hidden`)}else (e.type===`mouseout`||e.type===`touchend`)&&this.handleMouseOut(t)}getSliceAnchor(e){var t,n;let r=this.w,i=parseFloat((t=e==null?void 0:e.getAttribute(`data:cx`))==null?``:t),a=parseFloat((n=e==null?void 0:e.getAttribute(`data:cy`))==null?``:n);if(isNaN(i)||isNaN(a))return null;let o=r.dom.elWrap.getBoundingClientRect(),s=typeof e.getScreenCTM==`function`?e.getScreenCTM():null;if(!s){let e=r.dom.Paper.node.getBoundingClientRect();return{x:e.left-o.left+i,y:e.top-o.top+a}}return{x:s.a*i+s.c*a+s.e-o.left,y:s.b*i+s.d*a+s.f-o.top}}nonAxisChartsTooltips({e,opt:t,tooltipRect:n}){var r,i,a,o;let s=this.w,c=t.paths.getAttribute(`rel`),u=this.getElTooltip();if(!u)return;let d=s.dom.elWrap.getBoundingClientRect();if(e.type===`mousemove`||e.type===`touchmove`){if(s.dom.baseEl.classList.add(`apexcharts-tooltip-active`),u.classList.add(`apexcharts-active`),s.config.chart.accessibility.enabled&&s.config.chart.accessibility.announcements.enabled&&u.removeAttribute(`aria-hidden`),s.config.chart.type===`unit`){let t=Utils2.hoverTarget(e),n=t&&typeof t.closest==`function`?t.closest(`.apexcharts-unit-area`):null;if(!n)return;this.renderUnitTooltip(n)}else this.tooltipLabels.drawSeriesTexts({ttItems:t.ttItems,i:parseInt(c,10)-1,shared:!1});let o,f,p=t.paths.querySelector(`path[data\\:cx]`)||t.paths,m=s.config.tooltip.intersect?this.getSliceAnchor(p):null;if(m?(o=m.x-n.ttWidth/2,f=m.y-n.ttHeight-10):(o=((r=s.interact.clientX)==null?0:r)-d.left-n.ttWidth/2,f=((i=s.interact.clientY)==null?0:i)-d.top-n.ttHeight-10),u.style.left=o+`px`,u.style.top=f+`px`,s.config.legend.tooltipHoverFormatter){let e=s.config.legend.tooltipHoverFormatter,t=c-1,n=(a=this.legendLabels)==null?void 0:a[t];if(!n)return;n.innerHTML=e(n.getAttribute(`data:default-text`),{seriesIndex:t,dataPointIndex:t,w:s})}}else (e.type===`mouseout`||e.type===`touchend`)&&(u.classList.remove(`apexcharts-active`),s.dom.baseEl.classList.remove(`apexcharts-tooltip-active`),s.config.legend.tooltipHoverFormatter&&((o=this.legendLabels)==null||o.forEach(e=>{let t=e.getAttribute(`data:default-text`);e.innerHTML=decodeURIComponent(t==null?``:t)})))}renderUnitTooltip(e){var t,n,r,i,a;let o=this.w,s=this.getElTooltip();if(!s)return;let c=parseInt(e.getAttribute(`i`)||`0`,10),u=parseInt(e.getAttribute(`j`)||`0`,10);if(typeof o.config.tooltip.custom==`function`){this.tooltipLabels.handleCustomTooltip({i:c,j:u,y1:null,y2:null,w:o});return}let d=o.seriesData.seriesNames[c]||`series-${c+1}`,f=Math.round(Number(o.seriesData.series[c])||0),p=e.parentNode,m=p&&p.querySelectorAll?p.querySelectorAll(`.apexcharts-unit-area`).length:f,h=o.config.plotOptions.unit||{},g=h.unitValue>0?h.unitValue:1,_=o.seriesData.unitData&&o.seriesData.unitData[c],v=_?_[u]:void 0,y=v&&typeof v==`object`?v:null,b=y&&y.fillColor||o.globals.colors&&o.globals.colors[c]||`#008FFB`,x,S=h.tooltip&&h.tooltip.formatter;if(typeof S==`function`)x=S({seriesName:d,seriesIndex:c,dataPointIndex:u,count:m,value:f,unitValue:g,datum:v,color:b,w:o});else if(v!=null){let e=y?(r=(n=(t=y.name)==null?y.label:t)==null?y.x:n)==null?null:r:null,o=y?(a=(i=y.value)==null?y.y:i)==null?null:a:v;x=e!=null&&o!=null?`${e}: ${o}`:e==null?o==null?`#${(u+1).toLocaleString()} of ${m.toLocaleString()}`:String(o):String(e)}else x=`#${(u+1).toLocaleString()} of ${m.toLocaleString()}`,g!==1&&(x+=` &middot; ${g.toLocaleString()} per dot`);let C=o.config.chart.fontFamily||`inherit`,w=o.config.tooltip.style&&o.config.tooltip.style.fontSize||`12px`,T=s.querySelector(`.apexcharts-tooltip-arrow`);s.innerHTML=`<div class="apexcharts-tooltip-title" style="font-family: ${C}; font-size: ${w};">${d}</div><div class="apexcharts-tooltip-series-group apexcharts-active" style="display: flex;"><span class="apexcharts-tooltip-marker" style="background-color: ${b};"></span><div class="apexcharts-tooltip-text" style="font-family: ${C}; font-size: ${w};"><div class="apexcharts-tooltip-y-group"><span class="apexcharts-tooltip-text-y-value">${x}</span></div></div></div>`,T&&s.appendChild(T);let E=s.getBoundingClientRect();this.tooltipRect.ttWidth=E.width,this.tooltipRect.ttHeight=E.height}handleStickyTooltip(e,t,n,r){let i=this.w,a=this.tooltipUtil.getNearestValues({context:this,hoverArea:r.hoverArea,elGrid:r.elGrid,clientX:t,clientY:n}),o=a.j,s=a.capturedSeries;s!==null&&i.globals.collapsedSeriesIndices.includes(s==null?-1:s)&&(s=null);let c=i.globals.barPadForNumericAxis||0;if(a.hoverX<-c||a.hoverX>i.layout.gridWidth+c){this.handleMouseOut(r);return}if(s!==null)this.handleStickyCapturedSeries(e,s==null?-1:s,r,o==null?0:o);else if(this.tooltipUtil.isXoverlap(o==null?0:o)||i.globals.isBarHorizontal){let t=i.seriesData.series.findIndex((e,t)=>!i.globals.collapsedSeriesIndices.includes(t));this.create(e,this,t,o==null?0:o,r.ttItems)}}handleStickyCapturedSeries(e,t,n,r){let i=this.w;if(!this.tConfig.shared&&i.seriesData.series[t][r]===null){this.handleMouseOut(n);return}if(i.seriesData.series[t][r]!==void 0)this.tConfig.shared&&this.tooltipUtil.isXoverlap(r)&&this.tooltipUtil.isInitialSeriesSameLen()?this.create(e,this,t,r,n.ttItems):this.create(e,this,t,r,n.ttItems,!1);else if(this.tooltipUtil.isXoverlap(r)){let t=i.seriesData.series.findIndex((e,t)=>!i.globals.collapsedSeriesIndices.includes(t));this.create(e,this,t,r,n.ttItems)}}deactivateHoverFilter(){let e=this.w,t=new Graphics(this.w,this.ctx),n=e.dom.Paper.find(`.apexcharts-bar-area`);for(let e=0;e<n.length;e++)t.pathMouseLeave(n[e],void 0)}handleMouseOut(e){var t,n;let r=this.w,i=this.getElXCrosshairs();r.dom.baseEl.classList.remove(`apexcharts-tooltip-active`),e.tooltipEl.classList.remove(`apexcharts-active`),delete e.tooltipEl.dataset.positioned,r.config.chart.accessibility.enabled&&r.config.chart.accessibility.announcements.enabled&&e.tooltipEl.setAttribute(`aria-hidden`,`true`),this.deactivateHoverFilter(),r.config.chart.type!==`bubble`&&this.marker.resetPointsSize(),i!==null&&i.classList.remove(`apexcharts-active`);let a=this.ycrosshairs;if(a!==null&&a.classList.remove(`apexcharts-active`),this.isXAxisTooltipEnabled&&((t=this.xaxisTooltip)==null||t.classList.remove(`apexcharts-active`)),this.yaxisTooltips&&this.yaxisTooltips.length){this.yaxisTTEls===null&&(this.yaxisTTEls=[...r.dom.baseEl.querySelectorAll(`.apexcharts-yaxistooltip`)]);for(let e=0;e<this.yaxisTTEls.length;e++)this.yaxisTTEls[e].classList.remove(`apexcharts-active`)}r.config.legend.tooltipHoverFormatter&&((n=this.legendLabels)==null||n.forEach(e=>{let t=e.getAttribute(`data:default-text`);e.innerHTML=decodeURIComponent(t==null?``:t)}))}markerClick(e,t,n){let r=this.w;typeof r.config.chart.events.markerClick==`function`&&r.config.chart.events.markerClick(e,this.ctx,{seriesIndex:t,dataPointIndex:n,w:r}),this.ctx.events.fireEvent(`markerClick`,[e,this.ctx,{seriesIndex:t,dataPointIndex:n,w:r}])}_hasCustomSeries(){let e=this.w;return X(e.config.chart.type)?!0:(e.config.series||[]).some(e=>e&&e.type&&X(e.type))}create(e,t,n,r,i,a=null){var o,u,d,f,p,m,h,g,_,v,y,b,x,S,C,w,T,E,D,O,k;let j=this.w,M=t;e.type===`mouseup`&&this.markerClick(e,n,r),a===null&&(a=this.tConfig.shared);let N=this.tooltipUtil.hasMarkers(n),P=((u=(o=this.ctx)==null?void 0:o.renderer)==null?void 0:u.kind)===`canvas`,F=P&&!this.tooltipUtil.hasBars(),I=!P&&!N&&!this.tooltipUtil.hasBars()&&this._hasCustomSeries(),L=F||I,R=this.tooltipUtil.getElBars(),z=()=>{j.globals.markers.largestSize>0&&!P&&!j.globals.markers.batched?M.marker.enlargePoints(r):M.tooltipPosition.moveDynamicPointsOnHover(r)};if(j.config.legend.tooltipHoverFormatter){let e=j.config.legend.tooltipHoverFormatter,t=Array.from((d=this.legendLabels)==null?[]:d);t.forEach(e=>{let t=e.getAttribute(`data:default-text`);e.innerHTML=decodeURIComponent(t==null?``:t)});for(let i=0;i<t.length;i++){let o=t[i],s=parseInt((f=o.getAttribute(`i`))==null?``:f,10),c=decodeURIComponent((p=o.getAttribute(`data:default-text`))==null?``:p),u=e(c,{seriesIndex:a?s:n,dataPointIndex:r,w:j});if(a)o.innerHTML=j.globals.collapsedSeriesIndices.indexOf(s)<0?u:c;else if(o.innerHTML=s===n?u:c,n===s)break}}let B=j.rangeData,V=s(s({ttItems:i,i:n,j:r},((_=(g=(h=(m=B.seriesRange)==null?void 0:m[n])==null?void 0:h[r])==null?void 0:g.y[0])==null?void 0:_.y1)!==void 0&&{y1:(x=(b=(y=(v=B.seriesRange)==null?void 0:v[n])==null?void 0:y[r])==null?void 0:b.y[0])==null?void 0:x.y1}),((T=(w=(C=(S=B.seriesRange)==null?void 0:S[n])==null?void 0:C[r])==null?void 0:w.y[0])==null?void 0:T.y2)!==void 0&&{y2:(k=(O=(D=(E=B.seriesRange)==null?void 0:E[n])==null?void 0:D[r])==null?void 0:O.y[0])==null?void 0:k.y2});if(a){if(M.tooltipLabels.drawSeriesTexts(c(s({},V),{shared:this.showOnIntersect?!1:this.tConfig.shared})),N||L)z();else if(this.tooltipUtil.hasBars()&&(P&&M.tooltipPosition.moveStickyTooltipOverBars(r,n),this.barSeriesHeight=this.tooltipUtil.getBarsHeight([...R]),this.barSeriesHeight>0)){let e=new Graphics(this.w,this.ctx),t=j.dom.Paper.find(`.apexcharts-bar-area[j='${r}']`);this.deactivateHoverFilter(),M.tooltipUtil.getAllMarkers(!0).length&&!this.barSeriesHeight&&z(),M.tooltipPosition.moveStickyTooltipOverBars(r,n);for(let n=0;n<t.length;n++)e.pathMouseEnter(t[n],void 0)}}else M.tooltipLabels.drawSeriesTexts(s({shared:!1},V)),this.tooltipUtil.hasBars()&&M.tooltipPosition.moveStickyTooltipOverBars(r,n),N?M.tooltipPosition.moveMarkers(n,r):L&&M.tooltipPosition.moveDynamicPointOnHover(r,n)}}class SvgRenderer{constructor(e,t){this.w=e,this.ctx=t,this.kind=`svg`}beginSeries(){}present(){return null}clear(){}group(e){return this.ctx.graphics.group(e)}drawPath(e){return this.ctx.graphics.drawPath(e)}drawLine(...e){return this.ctx.graphics.drawLine(...e)}drawRect(...e){return this.ctx.graphics.drawRect(...e)}drawCircle(e,t){return this.ctx.graphics.drawCircle(e,t)}drawText(e){return this.ctx.graphics.drawText(e)}renderPaths(e){return this.ctx.graphics.renderPaths(e)}drawMarker(e,t,n={}){return this.ctx.graphics.drawMarker(e,t,n)}supports(e){return!0}hitTest(){return null}restyle(){}toBitmap(){return null}destroy(){}}const fn=`__apexcharts_renderers__`;function pn(){let e=globalThis;return e[fn]||(e[fn]=/* @__PURE__ */ new Map),e[fn]}class RendererController{static get _rendererRegistry(){return pn()}static registerRenderer(e,t){pn().set(e,t)}static unregisterRenderer(e){pn().delete(e)}constructor(e,t){this.w=e,this.ctx=t,this.svg=new SvgRenderer(e,t),this.active=this.svg,this._activeKind=`svg`,this._instances={}}_desiredKind(){let e=this.w.config.chart,t=e.renderer||`svg`;return!Environment.isBrowser()||t===`svg`||Ae(this.w)?`svg`:t===`canvas`||ke(this.w)>=(e.rendererThreshold||8e3)?`canvas`:`svg`}resolve(){let e=this.w.config.chart.renderer||`svg`,t=this._desiredKind();if(t!==`svg`){let n=pn().get(t);if(n)return this._instances[t]||(this._instances[t]=n(this.w,this.ctx)),this.active=this._instances[t],this._activeKind=t,this.ctx.renderer=this.active,this.w.globals.activeRenderer=this.active,this._activeKind;e===t&&console.warn(`[apexcharts] renderer:"${t}" requested but that renderer is not in the default bundle. Bundler: import 'apexcharts/features/renderer-${t}'. Script tag: add <script src=".../dist/features/renderer-${t}.js"> after apexcharts.js. Falling back to SVG.`)}else e===`canvas`&&Ae(this.w)&&console.warn(`[apexcharts] renderer:"canvas" requested but this chart uses a feature the canvas renderer does not render yet (gradient/pattern/image fill or a state color-matrix filter); falling back to SVG.`);return this.active=this.svg,this._activeKind=`svg`,this.ctx.renderer=this.active,this.w.globals.activeRenderer=this.active,this._activeKind}getActiveKind(){return this._activeKind}teardown(){for(let e in this._instances){let t=this._instances[e];t&&typeof t.destroy==`function`&&t.destroy()}this._instances={},this.active=this.svg,this._activeKind=`svg`}}class SVGElement{constructor(e){this.node=e,e&&(e.instance=this),this._listeners=[],this._filter=null}attr(e,t){if(typeof e==`string`&&t===void 0)return this.node.getAttribute(e);let n=typeof e==`string`?{[e]:t}:e;for(let e in n){let t=n[e];t===null?this.node.removeAttribute(e):t!==void 0&&(typeof t==`number`&&isNaN(t)&&(t=0),this.node.setAttribute(e,t))}if(this.node.nodeName===`text`&&n.x!=null){let e=this.node.querySelectorAll(`tspan[data-newline]`);for(let t=0;t<e.length;t++)e[t].setAttribute(`x`,n.x)}return this}css(e){for(let t in e)this.node.style[t]=e[t];return this}fill(e){return typeof e==`object`?this.attr(e):this.attr(`fill`,e)}stroke(e){return typeof e==`object`?(e.color!==void 0&&this.attr(`stroke`,e.color),e.width!==void 0&&this.attr(`stroke-width`,e.width),e.dasharray!==void 0&&this.attr(`stroke-dasharray`,e.dasharray),e.linecap!==void 0&&this.attr(`stroke-linecap`,e.linecap),e.opacity!==void 0&&this.attr(`stroke-opacity`,e.opacity),this):this.attr(`stroke`,e)}size(e,t){return this.attr({width:e,height:t})}move(e,t){return this.attr({x:e,y:t})}center(e,t){if(this.node.nodeName===`g`){let n=this.bbox(),r=e-(n.x+n.width/2),i=t-(n.y+n.height/2);return this.attr(`transform`,`translate(${r}, ${i})`)}return this.attr({cx:e,cy:t})}add(e){return e&&e.__isCanvasMark||this.node.appendChild(e.node||e),this}addTo(e){return(e.node||e).appendChild(this.node),this}remove(){return this.node.parentNode&&this.node.parentNode.removeChild(this.node),this}clear(){for(;this.node.firstChild;)this.node.removeChild(this.node.firstChild);return this}find(e){return Array.from(this.node.querySelectorAll(e)).map(e=>e.instance||new SVGElement(e))}findOne(e){let t=this.node.querySelector(e);return t?t.instance||new SVGElement(t):null}on(e,t){let n=e.split(`.`)[0];return this._listeners.push({event:e,eventType:n,handler:t}),this.node.addEventListener(n,t),this}off(e,t){if(!e&&!t)this._listeners.forEach(e=>{this.node.removeEventListener(e.eventType,e.handler)}),this._listeners=[];else if(e&&!t){let t=e.split(`.`)[0];this._listeners=this._listeners.filter(e=>e.eventType===t?(this.node.removeEventListener(e.eventType,e.handler),!1):!0)}else{let n=e.split(`.`)[0];this._listeners=this._listeners.filter(e=>e.eventType===n&&e.handler===t?(this.node.removeEventListener(e.eventType,e.handler),!1):!0)}return this}each(e,t){return Array.from(this.node.children).forEach(n=>{let r=n.instance||new SVGElement(n);e.call(r),t&&r.each(e,t)}),this}removeClass(e){return e===`*`?this.node.removeAttribute(`class`):this.node.classList.remove(e),this}children(){return Array.from(this.node.childNodes).filter(e=>e.nodeType===1).map(e=>e.instance||new SVGElement(e))}hide(){return this.node.style.display=`none`,this}show(){return this.node.style.display=``,this}bbox(){if(typeof this.node.getBBox==`function`)try{return this.node.getBBox()}catch(e){}return{x:0,y:0,width:0,height:0}}tspan(e){let t=BrowserAPIs.createElementNS(`http://www.w3.org/2000/svg`,`tspan`);return t.textContent=e,this.node.appendChild(t),new SVGElement(t)}plot(e){return typeof e==`string`&&this.attr(`d`,e),this}animate(){throw Error(`Animation module not loaded`)}filterWith(){throw Error(`Filter module not loaded`)}}let mn=0;class SVGGradient extends SVGElement{constructor(e,t,n){let r=t===`radial`?`radialGradient`:`linearGradient`,i=BrowserAPIs.createElementNS(P,r);super(i),this._id=`SvgjsGradient`+ ++mn,this.attr(`id`,this._id),typeof n==`function`&&n(new StopBuilder(this));let a=e.node.querySelector(`defs`);a||(a=BrowserAPIs.createElementNS(P,`defs`),e.node.appendChild(a)),a.appendChild(this.node)}stop(e,t,n){let r=BrowserAPIs.createElementNS(P,`stop`);return r.setAttribute(`offset`,e),r.setAttribute(`stop-color`,t),n!==void 0&&r.setAttribute(`stop-opacity`,String(n)),this.node.appendChild(r),this}from(e,t){return this.attr({x1:e,y1:t})}to(e,t){return this.attr({x2:e,y2:t})}url(){return`url(#`+this._id+`)`}toString(){return this.url()}valueOf(){return this.url()}fill(){return this.url()}}class StopBuilder{constructor(e){this.gradient=e}stop(e,t,n){return this.gradient.stop(e,t,n),this}}let hn=0;class SVGPattern extends SVGElement{constructor(e,t,n,r){let i=BrowserAPIs.createElementNS(P,`pattern`);super(i),this._id=`SvgjsPattern`+ ++hn,this.attr({id:this._id,width:t,height:n,patternUnits:`userSpaceOnUse`}),typeof r==`function`&&r(new SVGContainer(this.node));let a=e.node.querySelector(`defs`);a||(a=BrowserAPIs.createElementNS(P,`defs`),e.node.appendChild(a)),a.appendChild(this.node)}url(){return`url(#`+this._id+`)`}toString(){return this.url()}valueOf(){return this.url()}fill(){return this.url()}}class SVGContainer extends SVGElement{line(e,t,n,r){let i=this._make(`line`);return e!==void 0&&i.attr({x1:e,y1:t,x2:n,y2:r}),i}rect(e,t){let n=this._make(`rect`);return e!==void 0&&n.attr({width:e,height:t}),n}circle(e){let t=this._make(`circle`);return e!==void 0&&t.attr({r:e/2,cx:e/2,cy:e/2}),t}path(e){let t=this._make(`path`);return e&&t.attr(`d`,e),t}polygon(e){let t=this._make(`polygon`);return e&&t.attr(`points`,e),t}group(){return this._makeContainer(`g`)}defs(){return this._makeContainer(`defs`)}plain(e){let t=BrowserAPIs.createElementNS(P,`text`);t.textContent=e;let n=new SVGElement(t);return this.node.appendChild(t),n}text(e){let t=BrowserAPIs.createElementNS(P,`text`),n=new SVGElement(t);return this.node.appendChild(t),typeof e==`function`&&e(new TspanBuilder(t)),n}image(e,t){let n=BrowserAPIs.createElementNS(P,`image`);n.setAttributeNS(`http://www.w3.org/1999/xlink`,`href`,e);let r=new SVGElement(n);if(this.node.appendChild(n),typeof t==`function`&&Environment.isBrowser()){let n=new Image;n.onload=function(){r.size(n.width,n.height),t.call(r,{width:n.width,height:n.height})},n.src=e}return r}gradient(e,t){return new SVGGradient(this,e,t)}pattern(e,t,n){return new SVGPattern(this,e,t,n)}_make(e){let t=BrowserAPIs.createElementNS(P,e);return this.node.appendChild(t),new SVGElement(t)}_makeContainer(e){let t=BrowserAPIs.createElementNS(P,e);return this.node.appendChild(t),new SVGContainer(t)}}class TspanBuilder{constructor(e){this.textNode=e}tspan(e){let t=BrowserAPIs.createElementNS(P,`tspan`);return t.textContent=e,this.textNode.appendChild(t),new TspanWrapper(t,this.textNode)}}class TspanWrapper{constructor(e,t){this.node=e,this.textNode=t}newLine(){return this.node.setAttribute(`dy`,`1.1em`),this.node.dataset.newline=`1`,this}}let gn=0;class SVGFilter extends SVGElement{constructor(){let e=BrowserAPIs.createElementNS(P,`filter`);super(e),this._id=`SvgjsFilter`+ ++gn,this.attr(`id`,this._id)}}class FilterBuilder{constructor(e){this.filter=e}colorMatrix(e){return this._primitive(`feColorMatrix`,e)}offset(e){return this._primitive(`feOffset`,e)}gaussianBlur(e){return this._primitive(`feGaussianBlur`,e)}flood(e){return this._primitive(`feFlood`,e)}composite(e){return this._primitive(`feComposite`,e)}merge(e){let t=BrowserAPIs.createElementNS(P,`feMerge`);return e.forEach(e=>{let n=BrowserAPIs.createElementNS(P,`feMergeNode`);n.setAttribute(`in`,e),t.appendChild(n)}),this.filter.node.appendChild(t),new SVGElement(t)}_primitive(e,t){let n=BrowserAPIs.createElementNS(P,e);for(let e in t)n.setAttribute(e,t[e]);return this.filter.node.appendChild(n),new SVGElement(n)}}function _n(e){e.prototype.filterWith=function(e){let t=new SVGFilter;this._filter=t;let n=this.node;for(;n&&n.nodeName!==`svg`;)n=n.parentNode;if(n){let e=n.querySelector(`defs`);e||(e=BrowserAPIs.createElementNS(P,`defs`),n.insertBefore(e,n.firstChild)),e.appendChild(t.node)}return e(new FilterBuilder(t)),this.attr(`filter`,`url(#`+t._id+`)`),this},e.prototype.unfilter=function(e){return this._filter&&(this.node.removeAttribute(`filter`),e&&this._filter.node&&this._filter.node.parentNode&&this._filter.node.parentNode.removeChild(this._filter.node),this._filter=null),this},e.prototype.filterer=function(){return this._filter}}function vn(e){e.prototype.draggable=function(e){if(e===!1)return this._dragCleanup&&(this._dragCleanup(),this._dragCleanup=null),this;let t=this,n=e||{},r=e=>{if(e.button&&e.button!==0)return;e.stopPropagation();let r=e.type===`touchstart`?e.touches[0]:e,i=t.node,a=parseFloat(i.getAttribute(`x`))||0,o=parseFloat(i.getAttribute(`y`))||0,s=r.clientX,c=r.clientY,u=i.ownerSVGElement,d=null;u&&(d=u.getScreenCTM());let f=e=>{let t=e.type===`touchmove`?e.touches[0]:e,r=t.clientX-s,u=t.clientY-c;d&&(r/=d.a,u/=d.d);let f=a+r,p=o+u,m=parseFloat(i.getAttribute(`width`))||0,h=parseFloat(i.getAttribute(`height`))||0;n.minX!==void 0&&f<n.minX&&(f=n.minX),n.minY!==void 0&&p<n.minY&&(p=n.minY),n.maxX!==void 0&&f+m>n.maxX&&(f=n.maxX-m),n.maxY!==void 0&&p+h>n.maxY&&(p=n.maxY-h);let g={x:f,y:p,w:m,h,x2:f+m,y2:p+h},_=new CustomEvent(`dragmove`,{detail:{handler:{move:function(e,t){i.setAttribute(`x`,e),i.setAttribute(`y`,t)}},box:g}});i.dispatchEvent(_)},p=()=>{Environment.isBrowser()&&(document.removeEventListener(`mousemove`,f),document.removeEventListener(`touchmove`,f),document.removeEventListener(`mouseup`,p),document.removeEventListener(`touchend`,p)),t._activeDrag=null};Environment.isBrowser()&&(document.addEventListener(`mousemove`,f),document.addEventListener(`touchmove`,f),document.addEventListener(`mouseup`,p),document.addEventListener(`touchend`,p),t._activeDrag={onMove:f,onUp:p})};return t.node.addEventListener(`mousedown`,r),t.node.addEventListener(`touchstart`,r),t._dragCleanup=()=>{t.node.removeEventListener(`mousedown`,r),t.node.removeEventListener(`touchstart`,r),t._activeDrag&&Environment.isBrowser()&&(document.removeEventListener(`mousemove`,t._activeDrag.onMove),document.removeEventListener(`touchmove`,t._activeDrag.onMove),document.removeEventListener(`mouseup`,t._activeDrag.onUp),document.removeEventListener(`touchend`,t._activeDrag.onUp),t._activeDrag=null)},t}}function yn(e){e.prototype.select=function(e){if(e===!1)return this._selectCleanup&&(this._selectCleanup(),this._selectCleanup=null),this;let t=this,{createHandle:n,updateHandle:r}=e,i=document.createElementNS(P,`g`);i.setAttribute(`class`,`svg_select_points`);let a=t.node.parentNode;a&&a.appendChild(i);let o={},s=[`t`,`b`,`l`,`r`,`lt`,`rt`,`lb`,`rb`];s.forEach((e,t)=>{let r=new SVGContainer(document.createElementNS(P,`g`));i.appendChild(r.node),o[e]={group:r,handle:n(r,[0,0],t,[],e)}});let c=()=>{let e=parseFloat(t.attr(`x`))||0,n=parseFloat(t.attr(`y`))||0,a=parseFloat(t.attr(`width`))||0,c=parseFloat(t.attr(`height`))||0,u=t.node.getAttribute(`transform`);u?i.setAttribute(`transform`,u):i.removeAttribute(`transform`);let d={t:[e+a/2,n],b:[e+a/2,n+c],l:[e,n+c/2],r:[e+a,n+c/2],lt:[e,n],rt:[e+a,n],lb:[e,n+c],rb:[e+a,n+c]};s.forEach(e=>{o[e]&&d[e]&&r(o[e].group,d[e])})};return c(),t._selectHandles=i,t._selectHandlesMap=o,t._updateSelectPositions=c,t._selectCleanup=()=>{i.parentNode&&i.parentNode.removeChild(i),t._selectHandles=null,t._selectHandlesMap=null,t._updateSelectPositions=null},t},e.prototype.resize=function(e){if(e===!1)return this._resizeCleanup&&(this._resizeCleanup(),this._resizeCleanup=null),this;let t=this,n=t._selectHandlesMap;if(!n)return t;let r=[],i=e=>{let i=n[e];if(!i||!i.group||!i.group.node)return;let a=i.group.node,o=n=>{if(n.button&&n.button!==0)return;n.stopPropagation();let r=(n.type===`touchstart`?n.touches[0]:n).clientX,i=t.node.ownerSVGElement,a=null;i&&(a=i.getScreenCTM());let o=parseFloat(t.attr(`x`))||0,s=parseFloat(t.attr(`width`))||0,c=n=>{let i=(n.type===`touchmove`?n.touches[0]:n).clientX-r;a&&(i/=a.a);let c=o,u=s;e===`l`?(c=o+i,u=s-i):e===`r`&&(u=s+i),u<0&&(u=0),t.attr({x:c,width:u}),t._updateSelectPositions&&t._updateSelectPositions();let d=new CustomEvent(`resize`,{detail:{el:t}});t.node.dispatchEvent(d)},u=()=>{Environment.isBrowser()&&(document.removeEventListener(`mousemove`,c),document.removeEventListener(`touchmove`,c),document.removeEventListener(`mouseup`,u),document.removeEventListener(`touchend`,u));let e=new CustomEvent(`resize`,{detail:{el:t}});t.node.dispatchEvent(e)};Environment.isBrowser()&&(document.addEventListener(`mousemove`,c),document.addEventListener(`touchmove`,c),document.addEventListener(`mouseup`,u),document.addEventListener(`touchend`,u))};a.addEventListener(`mousedown`,o),a.addEventListener(`touchstart`,o),r.push(()=>{a.removeEventListener(`mousedown`,o),a.removeEventListener(`touchstart`,o)})};return i(`l`),i(`r`),t._resizeCleanup=()=>{r.forEach(e=>e())},t}}_n(SVGElement),ue(SVGElement),vn(SVGElement),yn(SVGElement);function bn(){let e=new SVGContainer(BrowserAPIs.createElementNS(P,`svg`));return e.attr({xmlns:P}),e}bn.xlink=`http://www.w3.org/1999/xlink`,Environment.isBrowser()&&window.SVG===void 0&&(window.SVG=bn),Environment.isBrowser()?(window.SVG===void 0&&(window.SVG=bn),window.Apex===void 0&&(window.Apex={})):typeof global<`u`&&(global.Apex===void 0&&(global.Apex={}),global.SVG===void 0&&(global.SVG=bn));const xn=`__apexcharts_features_v1__`;globalThis[xn]||(globalThis[xn]=/* @__PURE__ */ new Map);function Sn(){return globalThis[xn]}class InitCtxVariables{static get _featureRegistry(){return Sn()}static registerFeatures(e){for(let[t,n]of Object.entries(e))InitCtxVariables._featureRegistry.set(t,n)}constructor(e){this.ctx=e,this.w=e.w}initModules(){this.ctx.publicMethods=/* @__PURE__ */ `updateOptions.updateSeries.appendData.appendSeries.isSeriesHidden.highlightSeries.toggleSeries.showSeries.hideSeries.setLocale.resetSeries.zoomX.toggleDataPointSelection.dataURI.exportToCSV.addXaxisAnnotation.addYaxisAnnotation.addPointAnnotation.clearAnnotations.removeAnnotation.drillDown.drillUp.drillToRoot.clearDrilldownCache.paper.getActiveRenderer.destroy`.split(`.`),this.ctx.eventList=[`click`,`mousedown`,`mousemove`,`mouseleave`,`touchstart`,`touchmove`,`touchleave`,`mouseup`,`touchend`,`keydown`,`keyup`],this.ctx.animations=new Animations(this.w,this.ctx),this.ctx.axes=new Axes(this.w,this.ctx),this.ctx.core=new Core(this.ctx.el,this.w,this.ctx),this.ctx.config=new Config({}),this.ctx.data=new Data(this.w,{resetGlobals:()=>this.ctx.core.resetGlobals(),isMultipleY:()=>this.ctx.core.isMultipleY()}),this.ctx.grid=new Grid(this.w,this.ctx),this.ctx.graphics=new Graphics(this.w,this.ctx),this.ctx.coreUtils=new CoreUtils(this.w),this.ctx.crosshairs=new Crosshairs(this.w),this.ctx.events=new Events(this.w,this.ctx),this.ctx.fill=new Fill(this.w),this.ctx.localization=new Localization(this.w),this.ctx.options=new Options,this.ctx.responsive=new Responsive(this.w),this.ctx.series=new Series(this.w,{toggleDataSeries:(...e)=>{var t;return(t=this.ctx.legend)==null?void 0:t.legendHelpers.toggleDataSeries(...e)},revertDefaultAxisMinMax:()=>this.ctx.updateHelpers.revertDefaultAxisMinMax(),updateSeries:(...e)=>this.ctx.updateHelpers._updateSeries(...e)}),this.ctx.theme=new Theme(this.w),this.ctx.formatters=new Formatters(this.w),this.ctx.titleSubtitle=new TitleSubtitle(this.w),this.ctx.dimensions=new Dimensions(this.w,this.ctx),this.ctx.updateHelpers=new UpdateHelpers(this.w,this.ctx),this.ctx.rendererController=new RendererController(this.w,this.ctx),this.ctx.renderer=this.ctx.rendererController.active;let e=new Tooltip(this.w,this.ctx);this.w.globals.tooltip=e,Object.defineProperty(this.ctx,"tooltip",{get(){return this.w.globals.tooltip},configurable:!0}),this._initOptionalModules()}_initOptionalModules(){let e=InitCtxVariables._featureRegistry,t=this.w,n=this.ctx,r=e.get(`exports`);n.exports=r?new r(t,n):null;let i=e.get(`legend`);n.legend=i?new i(t,n):null;let a=e.get(`morphTypeChange`);n.morphTypeChange=a?new a(t,n):null;let o=e.get(`drilldown`);n.drilldown=o?new o(t,n):null;let s=e.get(`perspectives`);n.perspectives=s?new s(t,n):null;let c=e.get(`storyboard`);n.storyboard=c?new c(t,n):null;let u=e.get(`history`);n.history=u?new u(t,n):null;let d=e.get(`linkedViews`);n.linkedViews=d?new d(t,n):null;let f=e.get(`ink`);n.ink=f?new f(t,n):null;let p=e.get(`measure`);n.measure=p?new p(t,n):null;let m=e.get(`contextMenu`);n.contextMenu=m?new m(t,n):null;let h=e.get(`weave`);n.weave=h?new h(t,n):null;let g=e.get(`waterfall`);n.waterfall=g?new g(t,n):null;let _=e.get(`streamgraph`);n.streamgraph=_?new _(t,n):null;let v=e.get(`trellis`);n.trellis=v?new v(t,n):null;let y=e.get(`osThemeWatcher`);n.osThemeWatcher=y?new y(t,n):null;let b=e.get(`toolbar`);Object.defineProperty(n,"toolbar",{get(){var e;return!this._toolbar&&b&&(this._toolbar=new b(t,this)),(e=this._toolbar)==null?null:e},configurable:!0});let x=e.get(`zoomPanSelection`);Object.defineProperty(n,"zoomPanSelection",{get(){var e;return!this._zoomPanSelection&&x&&(this._zoomPanSelection=new x(t,this)),(e=this._zoomPanSelection)==null?null:e},configurable:!0});let S=e.get(`keyboardNavigation`);Object.defineProperty(n,"keyboardNavigation",{get(){var e;return!this._keyboardNavigation&&S&&(this._keyboardNavigation=new S(t,this)),(e=this._keyboardNavigation)==null?null:e},configurable:!0})}}class Destroy{constructor(e){this.ctx=e,this.w=e.w}clear({isUpdating:e}){var t,n,r,i,a,o,s,c,u,d,f,p,m;(t=this.ctx.weave)==null||t.teardown(e),e||(this.w.globals.isDestroyed=!0),this.ctx._zoomPanSelection&&this.ctx._zoomPanSelection.destroy(),this.ctx._toolbar&&this.ctx._toolbar.destroy(),this.w.globals.resizeObserver&&typeof this.w.globals.resizeObserver.disconnect==`function`&&(this.w.globals.resizeObserver.disconnect(),this.w.globals.resizeObserver=null),PerformanceCache.invalidateAll(this.w),e?(this.ctx._zoomPanSelection=null,this.ctx._toolbar=null,(n=this.ctx._keyboardNavigation)==null||n.destroy(),this.ctx._keyboardNavigation=null):((r=this.ctx.perspectives)==null||r.teardown(),this.ctx.perspectives=null,(i=this.ctx.storyboard)==null||i.teardown(),this.ctx.storyboard=null,(a=this.ctx.history)==null||a.teardown(),this.ctx.history=null,(o=this.ctx.linkedViews)==null||o.teardown(),this.ctx.linkedViews=null,(s=this.ctx.trellis)==null||s.teardown(),this.ctx.trellis=null,(c=this.ctx.ink)==null||c.teardown(),this.ctx.ink=null,(u=this.ctx.measure)==null||u.teardown(),this.ctx.measure=null,(d=this.ctx.contextMenu)==null||d.teardown(),this.ctx.contextMenu=null,(f=this.ctx.osThemeWatcher)==null||f.teardown(),this.ctx.osThemeWatcher=null,this.ctx.weave=null,(m=(p=this.ctx.rendererController)==null?void 0:p.teardown)==null||m.call(p),this.ctx.rendererController=null,this.ctx.renderer=null,this.ctx.drilldown=null,this.ctx.morphTypeChange=null,this.ctx.exports=null,this.ctx.animations=null,this.ctx.axes=null,this.ctx.annotations=null,this.ctx.core=null,this.ctx.data=null,this.ctx.grid=null,this.ctx.series=null,this.ctx.responsive=null,this.ctx.theme=null,this.ctx.formatters=null,this.ctx.titleSubtitle=null,this.ctx.legend=null,this.ctx.dimensions=null,this.ctx.options=null,this.ctx.crosshairs=null,this.ctx._zoomPanSelection=null,this.ctx.updateHelpers=null,this.ctx._toolbar=null,this.ctx.localization=null,this.ctx._keyboardNavigation=null,this.ctx.w.globals.tooltip=null),this.clearDomElements({isUpdating:e})}killSVG(e){e.each(function(){this.removeClass(`*`),this.off()},!0),e.clear()}clearDomElements({isUpdating:e}){let t=this.w.dom;if(Environment.isBrowser()&&t.Paper){let n=t.Paper.node;n.parentNode&&n.parentNode.parentNode&&!e&&(n.parentNode.parentNode.style.minHeight=`unset`);let r=t.baseEl;if(r&&this.ctx.eventList.forEach(e=>{r.removeEventListener(e,this.ctx.events.documentEvent)}),this.ctx.el!==null)for(;this.ctx.el.firstChild;)this.ctx.el.removeChild(this.ctx.el.firstChild);this.killSVG(t.Paper),t.Paper.remove()}t.Paper=null,t.elWrap=null,t.elGraphical=null,t.elLegendWrap=null,t.elLegendForeign=null,t.baseEl=null,t.elGridRect=null,t.elGridRectMask=null,t.elGridRectBarMask=null,t.elGridRectMarkerMask=null,t.elForecastMask=null,t.elNonForecastMask=null,t.elDefs=null}}const Cn=`__apexcharts_unit_layouts__`;globalThis[Cn]||(globalThis[Cn]={});function wn(){return globalThis[Cn]}function Tn(e,t){if(!e||typeof e!=`string`){console.warn(`ApexCharts: registerUnitLayout requires a non-empty name.`);return}if(typeof t!=`function`){console.warn(`ApexCharts: registerUnitLayout("${e}") expects a function (objects, rect) => [{id, x, y}].`);return}wn()[e]=t}function En(e){delete wn()[e]}const Dn=`__apexcharts_unit_marks__`;globalThis[Dn]||(globalThis[Dn]={});function On(){return globalThis[Dn]}function kn(e,t){if(typeof e==`string`){let n=e.trim();return n?Object.freeze({name:t||`anonymous`,path:n,viewBox:[0,0,100,100]}):null}if(!e||typeof e!=`object`||typeof e.path!=`string`||!e.path.trim())return null;let n=Array.isArray(e.viewBox)&&e.viewBox.length===4?e.viewBox.map(Number):[0,0,100,100];return!n.every(e=>isFinite(e))||n[2]<=0||n[3]<=0?null:Object.freeze(c(s({},e),{name:t||e.name||`anonymous`,path:e.path.trim(),viewBox:n,fillRule:e.fillRule===`evenodd`?`evenodd`:void 0}))}function An(e,t){if(!e||typeof e!=`string`){console.warn(`ApexCharts: registerUnitMark requires a non-empty name.`);return}let n=kn(t,e);if(!n){console.warn(`ApexCharts: registerUnitMark("${e}") expects path data, or {path, viewBox?, fillRule?}.`);return}On()[e]=n}function jn(e){delete On()[e]}const Mn=`__apexcharts_row_sources__`;globalThis[Mn]||(globalThis[Mn]={});function Nn(){return globalThis[Mn]}function Pn(e,t){if(!e||typeof e!=`string`){console.warn(`ApexCharts: registerRowSource requires a non-empty name.`);return}if(typeof t!=`function`){console.warn(`ApexCharts: registerRowSource("${e}") expects a function (w, opts) => series.`);return}Nn()[e]=t}function Fn(e){return e&&Nn()[e]||null}function In(e){delete Nn()[e]}function Ln(e){let t=e&&e.config&&e.config.chart;return t?Fn(t.requestedType)||Fn(t.type):null}const Rn=`__apexcharts_plugins__`;function zn(){let e=globalThis;return e[Rn]||(e[Rn]={}),e[Rn]}function Bn(e){if(!e||typeof e.name!=`string`||typeof e.setup!=`function`){console.error(`[apexcharts] registerPlugin: a plugin needs a { name, setup } shape.`);return}zn()[e.name]=e}function Vn(e){delete zn()[e]}const Hn=/* @__PURE__ */ new WeakMap;function Un(e,t){if(Environment.isSSR())return;let n=!1;if(e.nodeType!==Node.DOCUMENT_FRAGMENT_NODE){let t=e.getBoundingClientRect();(e.style.display===`none`||t.width===0)&&(n=!0)}let r=new ResizeObserver(r=>{n&&t.call(e,r),n=!0});e.nodeType===Node.DOCUMENT_FRAGMENT_NODE?Array.from(e.children).forEach(e=>r.observe(e)):r.observe(e),Hn.set(t,r)}function Wn(e,t){if(Environment.isSSR())return;let n=Hn.get(t);n&&(n.disconnect(),Hn.delete(t))}const Gn=`@keyframes opaque {
  0% {
    opacity: 0
  }

  to {
    opacity: 1
  }
}

@keyframes resizeanim {

  0%,
  to {
    opacity: 0
  }
}

.apexcharts-canvas {
  position: relative;
  direction: ltr !important;
  user-select: none;
  /* Focus indicator colour. Themes override below. */
  --apexcharts-focus-color: #008FFB;
}

/* Dark theme & high-contrast: brighter focus colour for sufficient contrast. */
.apexcharts-canvas .apexcharts-theme-dark,
.apexcharts-theme-dark.apexcharts-canvas {
  --apexcharts-focus-color: #FFD500;
}
.apexcharts-canvas.apexcharts-high-contrast,
.apexcharts-high-contrast.apexcharts-canvas {
  --apexcharts-focus-color: #FFFF00;
}

/* Visually-hidden aria-live status region (WCAG 4.1.3 Status Messages). */
.apexcharts-sr-status {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* Respect OS-level reduced-motion preference (WCAG 2.3.3). */
@media (prefers-reduced-motion: reduce) {
  .apexcharts-canvas *,
  .apexcharts-canvas *::before,
  .apexcharts-canvas *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

.apexcharts-canvas ::-webkit-scrollbar {
  -webkit-appearance: none;
  width: 6px
}

.apexcharts-canvas ::-webkit-scrollbar-thumb {
  border-radius: 4px;
  background-color: rgba(0, 0, 0, .5);
  box-shadow: 0 0 1px rgba(255, 255, 255, .5);
  -webkit-box-shadow: 0 0 1px rgba(255, 255, 255, .5)
}

.apexcharts-inner {
  position: relative
}

.apexcharts-text tspan {
  font-family: inherit
}

rect.legend-mouseover-inactive,
.legend-mouseover-inactive rect,
.legend-mouseover-inactive path,
.legend-mouseover-inactive circle,
.legend-mouseover-inactive line,
.legend-mouseover-inactive text.apexcharts-yaxis-title-text,
.legend-mouseover-inactive text.apexcharts-yaxis-label {
  transition: .15s ease all;
  opacity: .2
}

/* Linked Views (#4): per-mark crossfilter dim. Applied to individual data
   marks (not whole series) whose x is outside the brushed range. Opacity is
   overridable per chart via the --apx-cf-dim custom property. */
.apexcharts-crossfilter-dimmed {
  transition: opacity .25s ease;
  opacity: var(--apx-cf-dim, .2)
}

/* Linked Views (#4): default styling for the built-in crossfilter data table
   (cf.dataTable). Deliberately light so host styles can override. */
.apexcharts-cf-table {
  border-collapse: collapse;
  width: 100%;
  font-size: 13px;
}
.apexcharts-cf-table caption {
  caption-side: bottom;
  text-align: right;
  padding: 6px 2px;
  font-size: 12px;
  opacity: .7
}
.apexcharts-cf-table th,
.apexcharts-cf-table td {
  padding: 6px 10px;
  text-align: left;
  border-bottom: 1px solid rgba(0, 0, 0, .08)
}
.apexcharts-cf-table th {
  font-weight: 600;
  border-bottom-width: 2px
}
.apexcharts-cf-table tbody tr:hover {
  background: rgba(99, 102, 241, .06)
}

/* Measure ruler (#18): measure / delta ruler.
   Theme via these classes or the --apx-measure-* custom properties below
   (config \`chart.measure.colors\` overrides both). The ruler group also carries
   a direction class: apexcharts-measure-up | -down | -flat.
   Element classes:
     .apexcharts-measure-band     shaded span band
     .apexcharts-measure-vline    vertical guide lines
     .apexcharts-measure-line     free-mode diagonal line
     .apexcharts-measure-label-bg readout box     .apexcharts-measure-label text
   Colors are applied as SVG presentation attributes, so any rule you write on
   these classes overrides them. */
.apexcharts-canvas {
  --apx-measure-up: #16a34a;
  --apx-measure-down: #dc2626;
  --apx-measure-neutral: #64748b;
  --apx-measure-guide: #94a3b8;
}
.apexcharts-measure-capture {
  cursor: crosshair;
}

/* Radial Actions (#chrome): right-click context menu. Theme via these classes
   or the --apx-menu-* custom properties. */
.apexcharts-canvas {
  --apx-menu-bg: #ffffff;
  --apx-menu-fg: #1e293b;
  --apx-menu-border: #e2e8f0;
  --apx-menu-hover: #f1f5f9;
  --apx-menu-shadow: rgba(15, 23, 42, 0.18);
}
.apexcharts-context-menu {
  min-width: 168px;
  padding: 4px;
  border-radius: 8px;
  background: var(--apx-menu-bg);
  border: 1px solid var(--apx-menu-border);
  box-shadow: 0 6px 22px var(--apx-menu-shadow);
  font-family: Helvetica, Arial, sans-serif;
  font-size: 13px;
  z-index: 20;
  user-select: none;
}
.apexcharts-context-menu-item {
  display: block;
  width: 100%;
  box-sizing: border-box;
  text-align: left;
  padding: 7px 12px;
  border: 0;
  border-radius: 5px;
  background: transparent;
  color: var(--apx-menu-fg);
  font: inherit;
  cursor: pointer;
}
.apexcharts-context-menu-item:hover,
.apexcharts-context-menu-item--active {
  background: var(--apx-menu-hover);
}
.apexcharts-context-menu-item:focus {
  outline: none;
}

/* Ink Layer (#7): the floating note editor card, opened by clicking an
   ink-managed annotation. Theme via these classes or the --apx-ink-* vars. */
.apexcharts-canvas {
  --apx-ink-card-bg: #ffffff;
  --apx-ink-card-fg: #1e293b;
  --apx-ink-card-border: #e2e8f0;
  --apx-ink-card-hover: #f1f5f9;
  --apx-ink-card-accent: #6366f1;
  --apx-ink-card-shadow: rgba(15, 23, 42, 0.18);
}
.apexcharts-ink-card {
  position: absolute;
  z-index: 25;
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 8px;
  border-radius: 8px;
  background: var(--apx-ink-card-bg);
  border: 1px solid var(--apx-ink-card-border);
  box-shadow: 0 6px 22px var(--apx-ink-card-shadow);
  font-family: Helvetica, Arial, sans-serif;
  font-size: 12px;
  color: var(--apx-ink-card-fg);
  user-select: none;
}
.apexcharts-ink-card-row {
  display: flex;
  align-items: center;
  gap: 4px;
}
.apexcharts-ink-card input.apexcharts-ink-editor {
  flex: 1 1 auto;
  width: 150px;
  min-width: 0;
  box-sizing: border-box;
  padding: 4px 6px;
  font: inherit;
  color: inherit;
  background: transparent;
  border: 1px solid var(--apx-ink-card-border);
  border-radius: 5px;
}
.apexcharts-ink-card input.apexcharts-ink-editor:focus {
  outline: none;
  border-color: var(--apx-ink-card-accent);
}
.apexcharts-ink-btn {
  flex: 0 0 auto;
  width: 24px;
  height: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border: 0;
  border-radius: 5px;
  background: transparent;
  color: inherit;
  font: inherit;
  font-size: 12px;
  line-height: 1;
  cursor: pointer;
}
.apexcharts-ink-btn:hover,
.apexcharts-ink-btn--active {
  background: var(--apx-ink-card-hover);
}
.apexcharts-ink-btn:focus-visible,
.apexcharts-ink-swatch:focus-visible {
  outline: 2px solid var(--apx-ink-card-accent);
  outline-offset: 1px;
}
.apexcharts-ink-btn--bold {
  font-weight: 700;
}
.apexcharts-ink-btn--delete:hover {
  color: #dc2626;
}
.apexcharts-ink-swatch {
  flex: 0 0 auto;
  width: 16px;
  height: 16px;
  padding: 0;
  border: 1px solid rgba(100, 116, 139, 0.45);
  border-radius: 50%;
  cursor: pointer;
}
.apexcharts-ink-swatch--active {
  box-shadow:
    0 0 0 2px var(--apx-ink-card-bg),
    0 0 0 4px var(--apx-ink-card-accent);
}
.apexcharts-ink-sep {
  flex: 0 0 auto;
  width: 1px;
  height: 16px;
  margin: 0 2px;
  background: var(--apx-ink-card-border);
}
.apexcharts-ink-cardlabel {
  flex: 0 0 auto;
  font-size: 10px;
  letter-spacing: 0.4px;
  text-transform: uppercase;
  opacity: 0.65;
  margin-right: 2px;
}
.apexcharts-ink-marker-size {
  flex: 0 0 auto;
  min-width: 16px;
  text-align: center;
  font-variant-numeric: tabular-nums;
}

.apexcharts-legend-text {
  padding-left: 15px;
  margin-left: -15px;
}

.apexcharts-legend-series[role="button"]:focus {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: 2px;
}

.apexcharts-legend-series[role="button"]:focus:not(:focus-visible) {
  outline: none;
}

.apexcharts-legend-series[role="button"]:focus-visible {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: 2px;
}

.apexcharts-series-collapsed {
  opacity: 0
}

/* A series still playing its exit tween stays painted so it can visibly shrink
   away, hiding it on the first frame leaves a hole in a stacked chart for the
   length of the animation. Dropped once the tween lands. */
.apexcharts-series-collapsed.apexcharts-series-collapsing {
  opacity: 1
}

/* Its labels ride the shrinking marks, but a mark runs out of room for its text
   well before it reaches zero, so fade them across the exit instead of holding
   them crisp over a sliver. Duration is set inline from dynamicAnimation.speed. */
.apexcharts-datalabels.apexcharts-series-collapsing {
  animation: apexcharts-datalabels-exit var(--apexcharts-dl-exit, 400ms) ease-in
    forwards;
}

@keyframes apexcharts-datalabels-exit {
  from {
    opacity: 1
  }
  to {
    opacity: 0
  }
}

.apexcharts-canvas svg:focus:not(:focus-visible) {
  outline: none;
}

/* Keyboard navigation focus indicator on SVG data elements.
   SVG elements don't support CSS outline, so we use stroke. */
.apexcharts-bar-area.apexcharts-keyboard-focused,
.apexcharts-candlestick-area.apexcharts-keyboard-focused,
.apexcharts-boxPlot-area.apexcharts-keyboard-focused,
.apexcharts-rangebar-area.apexcharts-keyboard-focused,
.apexcharts-pie-area.apexcharts-keyboard-focused,
.apexcharts-heatmap-rect.apexcharts-keyboard-focused,
.apexcharts-treemap-rect.apexcharts-keyboard-focused {
  stroke: var(--apexcharts-focus-color, #008FFB);
  stroke-width: 2;
  stroke-opacity: 1;
}

.apexcharts-tooltip {
  --apx-tt-bg: #ffffff;
  /* Shared by the body and the arrow's two outward facets, so the
   * hairline reads as one continuous outline around the whole shape.
   * Keep it strong enough to survive on its own: the shadow below is
   * elevation, not edge definition. */
  --apx-tt-border: rgba(15, 23, 42, 0.12);
  /* Elevation, in three layers: a tight contact shadow that anchors the
   * bottom edge, a directional key shadow for the lift, and a wide
   * ambient one that grounds the whole box. Each is weaker and more
   * diffuse than the last.
   *
   * A tooltip is unusual in that it floats over *data*, so reach costs
   * more than it does on a page: every pixel the shadow travels tints a
   * bar or a line the reader is trying to compare. These numbers are
   * tuned to keep the near-edge contrast that reads as elevation while
   * dropping the long low haze that only muddies the plot.
   *
   * Note there is deliberately no \`0 0 0 1px\` ring layer. That used to
   * stand in for edge definition back when --apx-tt-border was barely
   * visible; now that the border is a real hairline (and the arrow
   * shares it) a ring only double-draws the outline, and being spread
   * rather than offset it leaked ink upward too, flattening the lift.
   *
   * \`--apx-tt-shadow-dir\` flips the whole stack's Y in one place — see
   * the \`[data-placement="bottom"]\` rule further down. */
  --apx-tt-shadow-dir: 1;
  --apx-tt-shadow: 0 calc(var(--apx-tt-shadow-dir) * 1px) 2px rgba(15, 23, 42, 0.06), 0 calc(var(--apx-tt-shadow-dir) * 4px) 8px -2px rgba(15, 23, 42, 0.10), 0 calc(var(--apx-tt-shadow-dir) * 12px) 20px -8px rgba(15, 23, 42, 0.14);
  --apx-tt-arrow-bg: var(--apx-tt-bg);
  --apx-tt-color: #0f172a;
  --apx-tt-color-muted: rgba(15, 23, 42, 0.55);
  border-radius: 8px;
  background: var(--apx-tt-bg);
  border: 1px solid var(--apx-tt-border);
  box-shadow: var(--apx-tt-shadow);
  color: var(--apx-tt-color);
  cursor: default;
  font-size: 13px;
  left: 0;
  top: 0;
  opacity: 0;
  pointer-events: none;
  position: absolute;
  display: flex;
  flex-direction: column;
  padding: 2px 0;
  white-space: nowrap;
  z-index: 12;
  transition: opacity .12s ease
}

/* While the tooltip is visible, smoothly animate position changes
 * between data points. Kept short (160 ms) and ease-out so it stays
 * responsive — too long would feel laggy when sweeping across many
 * points fast. The position transition is only attached after the
 * first paint (Position.applyTooltipPosition flips \`data-positioned\`
 * once the tooltip has been placed) so the *first* show doesn't slide
 * the tooltip in from the previously-stale (0,0) coordinates. */
.apexcharts-tooltip.apexcharts-active {
  opacity: 1;
  transition: opacity .12s ease
}
.apexcharts-tooltip.apexcharts-active[data-positioned="true"] {
  transition: opacity .12s ease, left .16s ease-out, top .16s ease-out
}

.apexcharts-tooltip.apexcharts-theme-light {
  /* defaults already set above; class kept for backward-compat selectors */
}

.apexcharts-tooltip.apexcharts-theme-dark {
  --apx-tt-bg: #1c1c1f;
  --apx-tt-border: rgba(255, 255, 255, 0.16);
  /* Dark needs more alpha than light to register at all, but not as much
   * as it used to: the light rim above now carries the edge, so the
   * shadow is free to be pure elevation instead of doubling as an
   * outline. Same geometry as light, heavier ink. */
  --apx-tt-shadow: 0 calc(var(--apx-tt-shadow-dir) * 1px) 2px rgba(0, 0, 0, 0.24), 0 calc(var(--apx-tt-shadow-dir) * 4px) 8px -2px rgba(0, 0, 0, 0.30), 0 calc(var(--apx-tt-shadow-dir) * 12px) 20px -8px rgba(0, 0, 0, 0.38);
  --apx-tt-color: #f3f4f6;
  --apx-tt-color-muted: rgba(243, 244, 246, 0.55);
}

.apexcharts-tooltip * {
  font-family: inherit
}

/* Point-annotation hover tooltip (apexcharts/apexcharts.js#2424). Reuses the
 * glass body/border/shadow from \`.apexcharts-tooltip\` but holds free-form
 * content, so it needs its own padding, wrapping and a sane max width. */
.apexcharts-tooltip.apexcharts-annotation-tooltip {
  padding: 6px 10px;
  max-width: 240px;
  white-space: normal;
  line-height: 1.4;
  pointer-events: none;
  z-index: 13
}

.apexcharts-tooltip-title {
  padding: 8px 12px 4px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.01em;
  color: var(--apx-tt-color-muted);
  background: transparent;
  border-bottom: none;
  margin-bottom: 0
}

.apexcharts-tooltip.apexcharts-theme-light .apexcharts-tooltip-title,
.apexcharts-tooltip.apexcharts-theme-dark .apexcharts-tooltip-title {
  background: transparent;
  border-bottom: none
}

/* \`fillSeriesColor\`: each series-group already paints itself with the
 * series colour. Drop the glass body entirely (transparent bg, no
 * border, no backdrop-filter, no padding) and clip the coloured
 * series-group(s) to the tooltip's rounded corners so they fill the
 * shell edge-to-edge. Text inside the coloured group is forced to
 * white for contrast. */
.apexcharts-tooltip.apexcharts-tooltip-fill-series {
  background: transparent;
  -webkit-backdrop-filter: none;
  backdrop-filter: none;
  border: none;
  padding: 0;
  overflow: hidden;
  color: #fff
}

.apexcharts-tooltip.apexcharts-tooltip-fill-series .apexcharts-tooltip-title {
  background: rgba(0, 0, 0, 0.22);
  color: #fff;
  opacity: 1;
  padding: 6px 12px
}

.apexcharts-tooltip.apexcharts-tooltip-fill-series .apexcharts-tooltip-series-group {
  color: #fff
}

/* Arrow connector — a 45°-rotated square straddling the body's edge, so
 * the body's 1px border runs continuously out across the arrow and back.
 * The two facets that face away from the tooltip carry the border; the
 * two that face into it carry none, and the square's opaque fill covers
 * the segment of the body's own border it sits on, hiding the seam.
 *
 * This is why it's a rotated square and not a triangle: \`clip-path\`
 * erases \`border\` and \`box-shadow\` along with everything outside the
 * polygon, which left \`filter: drop-shadow\` as the only way to suggest
 * an edge — and a drop-shadow can only ever blur one, never draw a
 * hairline. Nothing here needs a filter.
 *
 * Geometry: a square of side S rotated 45° reaches S/√2 from its centre
 * to each corner, so S = 10px gives the ~7px tip overhang that
 * ARROW_TIP_OVERHANG assumes (tooltip/constants.js) over a ~14px base.
 * The offsets park the square's *centre* 1px outside the padding box
 * (-6px = -1px border - 10px/2), i.e. exactly on the body's border line,
 * so the two borders meet end to end instead of overlapping or gapping.
 * \`box-sizing\` must be border-box or the bordered sides would grow the
 * square asymmetrically and knock its centre off that line. */
.apexcharts-tooltip-arrow {
  position: absolute;
  box-sizing: border-box;
  width: 10px;
  height: 10px;
  background: var(--apx-tt-arrow-bg);
  transform: rotate(45deg);
  pointer-events: none;
  top: calc(var(--apx-tt-arrow-y, 50%) - 5px)
}

/* Which two sides face outward depends on the placement. Under
 * \`rotate(45deg)\` the square's bottom-left corner swings to the left,
 * top-right to the right, top-left to the top and bottom-right to the
 * bottom — so the pair of borders below is always the two sharing the
 * corner that ends up as the tip. */
.apexcharts-tooltip[data-placement="right"] .apexcharts-tooltip-arrow {
  left: -6px;
  border-left: 1px solid var(--apx-tt-border);
  border-bottom: 1px solid var(--apx-tt-border)
}

.apexcharts-tooltip[data-placement="left"] .apexcharts-tooltip-arrow {
  right: -6px;
  border-top: 1px solid var(--apx-tt-border);
  border-right: 1px solid var(--apx-tt-border)
}

/* Vertical arrow variants: tooltip is above/below the data point and the
 * arrow points down/up. The base rule above uses \`--apx-tt-arrow-y\` for
 * left/right placement; for top/bottom we centre on \`--apx-tt-arrow-x\`
 * instead (set by applyTooltipPosition). */
.apexcharts-tooltip[data-placement="top"] .apexcharts-tooltip-arrow,
.apexcharts-tooltip[data-placement="bottom"] .apexcharts-tooltip-arrow {
  top: auto;
  left: calc(var(--apx-tt-arrow-x, 50%) - 5px)
}

.apexcharts-tooltip[data-placement="top"] .apexcharts-tooltip-arrow {
  bottom: -6px;
  border-right: 1px solid var(--apx-tt-border);
  border-bottom: 1px solid var(--apx-tt-border)
}

.apexcharts-tooltip[data-placement="bottom"] .apexcharts-tooltip-arrow {
  top: -6px;
  border-top: 1px solid var(--apx-tt-border);
  border-left: 1px solid var(--apx-tt-border)
}

/* When the tooltip is flipped below the data point, the default
 * downward-biased shadow leaves its top edge undefined. Negating the
 * direction casts the whole elevation upward instead, so the shadow
 * falls between the tooltip and the mark above it. One multiplier flips
 * all three layers together; the arrow needs no counterpart, since its
 * border doesn't depend on light direction. */
.apexcharts-tooltip[data-placement="bottom"] {
  --apx-tt-shadow-dir: -1
}

.apexcharts-tooltip-text-goals-value,
.apexcharts-tooltip-text-y-value,
.apexcharts-tooltip-text-z-value {
  display: inline-block;
  margin-left: 5px;
  font-weight: 600
}

.apexcharts-tooltip-text-goals-label:empty,
.apexcharts-tooltip-text-goals-value:empty,
.apexcharts-tooltip-text-y-label:empty,
.apexcharts-tooltip-text-y-value:empty,
.apexcharts-tooltip-text-z-value:empty,
.apexcharts-tooltip-title:empty {
  display: none
}

.apexcharts-tooltip-text-goals-label,
.apexcharts-tooltip-text-goals-value {
  padding: 6px 0 5px
}

.apexcharts-tooltip-goals-group,
.apexcharts-tooltip-text-goals-label,
.apexcharts-tooltip-text-goals-value {
  display: flex
}

.apexcharts-tooltip-text-goals-label:not(:empty),
.apexcharts-tooltip-text-goals-value:not(:empty) {
  margin-top: -6px
}

.apexcharts-tooltip-marker {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  position: relative;
  width: 12px;
  height: 12px;
  margin-right: 6px;
  vertical-align: middle;
  color: inherit;
}

.apexcharts-tooltip-marker svg {
  width: 100%;
  height: 100%;
  display: block;
}

.apexcharts-tooltip-series-group {
  padding: 4px 12px;
  display: none;
  gap: 8px;
  text-align: left;
  justify-content: left;
  align-items: center
}

.apexcharts-tooltip-series-group.apexcharts-active .apexcharts-tooltip-marker {
  opacity: 1
}

.apexcharts-tooltip-series-group.apexcharts-active:last-child,
.apexcharts-tooltip-series-group:last-child {
  padding-bottom: 8px
}

.apexcharts-tooltip-y-group {
  padding: 6px 0 5px
}

/* \`tooltip.compact\`: a tight box instead of a card, for panels a normal card
   would cover (small multiples, sparklines, tiles). Only the box shrinks, so
   the arrow and every anchor rule still apply. Rows stay stacked when there
   are several series (the names are what tells them apart); a one-series
   chart collapses to a single line, see \`-value-only\` below. */
.apexcharts-tooltip.apexcharts-tooltip-compact {
  padding: 3px 8px;
  font-size: 11px;
  line-height: 1.35
}

.apexcharts-tooltip-compact .apexcharts-tooltip-title {
  padding: 0;
  font-size: 11px;
  white-space: nowrap
}

.apexcharts-tooltip-compact .apexcharts-tooltip-series-group,
.apexcharts-tooltip-compact .apexcharts-tooltip-series-group.apexcharts-active:last-child,
.apexcharts-tooltip-compact .apexcharts-tooltip-series-group:last-child {
  padding: 0;
  gap: 5px
}

.apexcharts-tooltip-compact .apexcharts-tooltip-y-group {
  padding: 0
}

.apexcharts-tooltip-compact .apexcharts-tooltip-marker {
  width: 8px;
  height: 8px
}

/* A one-series panel: the series name repeats what the panel header already
   says, so the value stands alone and the x label becomes its prefix on one
   line ("Aug 2024  6.59"). */
.apexcharts-tooltip.apexcharts-tooltip-compact.apexcharts-tooltip-value-only {
  /* The tooltip body is a flex COLUMN by default (title row, then series
     rows); one series needs no column, so the same box turns into one line. */
  flex-direction: row;
  align-items: baseline;
  gap: 6px
}

.apexcharts-tooltip-value-only .apexcharts-tooltip-marker {
  display: none
}

.apexcharts-tooltip-value-only .apexcharts-tooltip-text-y-label {
  display: none
}

.apexcharts-custom-tooltip,
.apexcharts-tooltip-box {
  padding: 4px 8px
}

.apexcharts-tooltip-boxPlot {
  display: flex;
  flex-direction: column-reverse
}

.apexcharts-tooltip-box>div {
  margin: 4px 0
}

.apexcharts-tooltip-box span.value {
  font-weight: 700
}

.apexcharts-tooltip-rangebar {
  padding: 5px 8px
}

.apexcharts-tooltip-rangebar .category {
  font-weight: 600;
  color: #777
}

.apexcharts-tooltip-rangebar .series-name {
  font-weight: 700;
  display: block;
  margin-bottom: 5px
}

/* Streamgraph: every band read out at one column, top-down in stacking order.
 * A row per band rather than the shared tooltip's list, because a streamgraph's
 * \`[lo, hi]\` are stacking offsets and the values the reader gave live on
 * w.streamgraphData. */
.apexcharts-tooltip-stream {
  padding: 5px 8px
}

.apexcharts-tooltip-stream .apexcharts-tooltip-title {
  background: transparent;
  border: 0;
  padding: 0 0 4px;
  margin: 0;
  font-weight: 700
}

.apexcharts-tooltip-stream-band {
  display: flex;
  align-items: center;
  gap: 5px;
  line-height: 1.6;
  opacity: .72
}

.apexcharts-tooltip-stream-band.apexcharts-active {
  opacity: 1;
  font-weight: 700
}

.apexcharts-tooltip-stream-band .series-name {
  flex: 1 1 auto;
  margin-right: 8px
}

.apexcharts-tooltip-stream-band .value {
  font-weight: 700;
  margin-left: auto
}

.apexcharts-tooltip-stream-total {
  display: flex;
  align-items: center;
  margin-top: 4px;
  padding-top: 4px;
  border-top: 1px solid var(--apx-tt-border, rgba(15, 23, 42, .12))
}

.apexcharts-tooltip-stream-total .series-name {
  flex: 1 1 auto;
  font-weight: 600
}

.apexcharts-tooltip-stream-total .value {
  font-weight: 700;
  margin-left: auto
}

/* The band labels themselves. Pointer events off so a name never blocks a
 * hover on the band it sits on. */
.apexcharts-streamgraph-label {
  pointer-events: none
}

/* X/Y axis tooltips — small popovers that label the crosshair on the
 * axes. Restyled to match the modern data-tooltip palette: solid white
 * body with a subtle border + soft drop-shadow, smaller font, rounded
 * corners. The arrows still use the CSS border-triangle technique
 * (cheap, crisp at small sizes); their colours flow from CSS variables
 * so light/dark themes only need one override per axis. */
.apexcharts-xaxistooltip,
.apexcharts-yaxistooltip {
  --apx-axt-bg: #ffffff;
  --apx-axt-border: rgba(15, 23, 42, 0.08);
  --apx-axt-color: #0f172a;
  --apx-axt-shadow: 0 4px 12px -4px rgba(15, 23, 42, 0.18), 0 1px 3px -1px rgba(15, 23, 42, 0.12);
  opacity: 0;
  pointer-events: none;
  color: var(--apx-axt-color);
  font-size: 12px;
  font-weight: 500;
  text-align: center;
  border-radius: 6px;
  position: absolute;
  z-index: 10;
  background: var(--apx-axt-bg);
  border: 1px solid var(--apx-axt-border);
  box-shadow: var(--apx-axt-shadow)
}

.apexcharts-xaxistooltip.apexcharts-theme-dark,
.apexcharts-yaxistooltip.apexcharts-theme-dark {
  --apx-axt-bg: #1c1c1f;
  --apx-axt-border: rgba(255, 255, 255, 0.1);
  --apx-axt-color: #f3f4f6;
  --apx-axt-shadow: 0 4px 12px -4px rgba(0, 0, 0, 0.55), 0 1px 3px -1px rgba(0, 0, 0, 0.45)
}

.apexcharts-xaxistooltip {
  padding: 4px 8px;
  transition: .15s ease all
}

.apexcharts-xaxistooltip:after,
.apexcharts-xaxistooltip:before {
  left: 50%;
  border: solid transparent;
  content: " ";
  height: 0;
  width: 0;
  position: absolute;
  pointer-events: none
}

/* :before paints the 1px border outline of the triangle (slightly larger
 * than :after); :after sits inside and paints the fill — leaves a 1px
 * ring of :before visible at the edges. */
.apexcharts-xaxistooltip:after {
  border-color: transparent;
  border-width: 5px;
  margin-left: -5px
}

.apexcharts-xaxistooltip:before {
  border-color: transparent;
  border-width: 6px;
  margin-left: -6px
}

.apexcharts-xaxistooltip-bottom:after,
.apexcharts-xaxistooltip-bottom:before {
  bottom: 100%
}

.apexcharts-xaxistooltip-top:after,
.apexcharts-xaxistooltip-top:before {
  top: 100%
}

.apexcharts-xaxistooltip-bottom:after {
  border-bottom-color: var(--apx-axt-bg)
}

.apexcharts-xaxistooltip-bottom:before {
  border-bottom-color: var(--apx-axt-border)
}

.apexcharts-xaxistooltip-top:after {
  border-top-color: var(--apx-axt-bg)
}

.apexcharts-xaxistooltip-top:before {
  border-top-color: var(--apx-axt-border)
}

.apexcharts-xaxistooltip.apexcharts-active {
  opacity: 1;
  transition: .15s ease all
}

.apexcharts-yaxistooltip {
  padding: 3px 8px
}

.apexcharts-yaxistooltip:after,
.apexcharts-yaxistooltip:before {
  top: 50%;
  border: solid transparent;
  content: " ";
  height: 0;
  width: 0;
  position: absolute;
  pointer-events: none
}

.apexcharts-yaxistooltip:after {
  border-color: transparent;
  border-width: 5px;
  margin-top: -5px
}

.apexcharts-yaxistooltip:before {
  border-color: transparent;
  border-width: 6px;
  margin-top: -6px
}

.apexcharts-yaxistooltip-left:after,
.apexcharts-yaxistooltip-left:before {
  left: 100%
}

.apexcharts-yaxistooltip-right:after,
.apexcharts-yaxistooltip-right:before {
  right: 100%
}

.apexcharts-yaxistooltip-left:after {
  border-left-color: var(--apx-axt-bg)
}

.apexcharts-yaxistooltip-left:before {
  border-left-color: var(--apx-axt-border)
}

.apexcharts-yaxistooltip-right:after {
  border-right-color: var(--apx-axt-bg)
}

.apexcharts-yaxistooltip-right:before {
  border-right-color: var(--apx-axt-border)
}

.apexcharts-yaxistooltip.apexcharts-active {
  opacity: 1
}

.apexcharts-yaxistooltip-hidden {
  display: none
}

.apexcharts-xcrosshairs,
.apexcharts-ycrosshairs {
  pointer-events: none;
  opacity: 0;
  transition: .15s ease all
}

.apexcharts-xcrosshairs.apexcharts-active,
.apexcharts-ycrosshairs.apexcharts-active {
  opacity: 1;
  transition: .15s ease all
}

.apexcharts-ycrosshairs-hidden {
  opacity: 0
}

.apexcharts-selection-rect {
  cursor: move
}

.svg_select_shape {
  stroke-width: 1;
  stroke-dasharray: 10 10;
  stroke: black;
  stroke-opacity: 0.1;
  pointer-events: none;
  fill: none;
}

.svg_select_handle {
  stroke-width: 3;
  stroke: black;
  fill: none;
}

.svg_select_handle_r {
  cursor: e-resize;
}

.svg_select_handle_l {
  cursor: w-resize;
}

.apexcharts-svg.apexcharts-zoomable.hovering-zoom {
  cursor: crosshair
}

.apexcharts-svg.apexcharts-zoomable.hovering-pan {
  cursor: move
}

.apexcharts-menu-icon,
.apexcharts-measure-icon,
.apexcharts-pan-icon,
.apexcharts-reset-icon,
.apexcharts-selection-icon,
.apexcharts-toolbar-custom-icon,
.apexcharts-zoom-icon,
.apexcharts-zoomin-icon,
.apexcharts-zoomout-icon {
  cursor: pointer;
  /* WCAG 2.5.8 Target Size (Minimum): 24×24 CSS px hit target. */
  width: 26px;
  height: 24px;
  line-height: 24px;
  color: #6e8192;
  text-align: center;
  /* Reset native <button> chrome — these are styled via SVG icons. */
  padding: 0;
  margin: 0;
  background: transparent;
  border: 0;
  border-radius: 5px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: background-color .12s ease, color .12s ease;
}

.apexcharts-menu-icon svg,
.apexcharts-measure-icon svg,
.apexcharts-pan-icon svg,
.apexcharts-reset-icon svg,
.apexcharts-selection-icon svg,
.apexcharts-zoom-icon svg,
.apexcharts-zoomin-icon svg,
.apexcharts-zoomout-icon svg {
  width: 18px;
  height: 18px;
  fill: none;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round
}

.apexcharts-theme-dark .apexcharts-menu-icon,
.apexcharts-theme-dark .apexcharts-measure-icon,
.apexcharts-theme-dark .apexcharts-pan-icon,
.apexcharts-theme-dark .apexcharts-reset-icon,
.apexcharts-theme-dark .apexcharts-selection-icon,
.apexcharts-theme-dark .apexcharts-toolbar-custom-icon,
.apexcharts-theme-dark .apexcharts-zoom-icon,
.apexcharts-theme-dark .apexcharts-zoomin-icon,
.apexcharts-theme-dark .apexcharts-zoomout-icon {
  color: #d4d6dc
}

.apexcharts-canvas .apexcharts-measure-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-pan-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-reset-zoom-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-selection-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-zoom-icon.apexcharts-selected {
  background: rgba(0, 143, 251, 0.12);
  color: #008ffb
}

.apexcharts-theme-light .apexcharts-menu-icon:hover,
.apexcharts-theme-light .apexcharts-measure-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-pan-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-reset-icon:hover,
.apexcharts-theme-light .apexcharts-selection-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-zoom-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-zoomin-icon:hover,
.apexcharts-theme-light .apexcharts-zoomout-icon:hover {
  background: rgba(15, 23, 42, 0.06);
  color: #1f2937
}

.apexcharts-theme-dark .apexcharts-menu-icon:hover,
.apexcharts-theme-dark .apexcharts-measure-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-pan-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-reset-icon:hover,
.apexcharts-theme-dark .apexcharts-selection-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-zoom-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-zoomin-icon:hover,
.apexcharts-theme-dark .apexcharts-zoomout-icon:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #fff
}

.apexcharts-menu-icon,
.apexcharts-selection-icon {
  position: relative
}

.apexcharts-toolbar {
  position: absolute;
  z-index: 11;
  display: inline-flex;
  align-items: center;
  gap: 1px;
  padding: 3px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.apexcharts-theme-dark .apexcharts-toolbar {
  background: rgba(28, 28, 31, 0.82);
}

.apexcharts-menu {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  position: absolute;
  top: calc(100% + 4px);
  border: 1px solid rgba(15, 23, 42, 0.08);
  border-radius: 8px;
  padding: 4px;
  right: 0;
  opacity: 0;
  min-width: 120px;
  transition: opacity .15s ease, transform .15s ease;
  transform: translateY(-2px);
  pointer-events: none;
  box-shadow: 0 4px 16px -4px rgba(15, 23, 42, 0.12), 0 2px 4px -1px rgba(15, 23, 42, 0.06)
}

.apexcharts-menu.apexcharts-menu-open {
  opacity: 1;
  transform: translateY(0);
  pointer-events: all
}

.apexcharts-menu-item {
  padding: 6px 9px;
  font-size: 12px;
  border-radius: 5px;
  cursor: pointer
}

.apexcharts-theme-light .apexcharts-menu-item:hover {
  background: rgba(15, 23, 42, 0.06)
}

.apexcharts-theme-dark .apexcharts-menu {
  background: rgba(28, 28, 31, 0.92);
  border-color: rgba(255, 255, 255, 0.08);
  color: #f3f4f6;
  box-shadow: 0 4px 16px -4px rgba(0, 0, 0, 0.5), 0 2px 4px -1px rgba(0, 0, 0, 0.4)
}

.apexcharts-theme-dark .apexcharts-menu-item:hover {
  background: rgba(255, 255, 255, 0.08)
}

@media screen and (min-width:768px) {
  .apexcharts-canvas:hover .apexcharts-toolbar {
    opacity: 1
  }
}

/* Toolbar keyboard accessibility: show toolbar when any button inside it is focused */
.apexcharts-toolbar:focus-within {
  opacity: 1
}

/* Focus indicator for toolbar icon buttons */
.apexcharts-menu-icon:focus-visible,
.apexcharts-measure-icon:focus-visible,
.apexcharts-pan-icon:focus-visible,
.apexcharts-reset-icon:focus-visible,
.apexcharts-selection-icon:focus-visible,
.apexcharts-toolbar-custom-icon:focus-visible,
.apexcharts-zoom-icon:focus-visible,
.apexcharts-zoomin-icon:focus-visible,
.apexcharts-zoomout-icon:focus-visible {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: 1px;
  border-radius: 5px
}

/* Focus indicator for hamburger menu items */
.apexcharts-menu-item:focus-visible {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: -2px;
  background: #eee
}

.apexcharts-canvas .apexcharts-element-hidden,
.apexcharts-datalabel.apexcharts-element-hidden,
.apexcharts-hide .apexcharts-series-points {
  opacity: 0;
}

.apexcharts-hidden-element-shown {
  opacity: 1;
  transition: 0.25s ease all;
}

.apexcharts-datalabel,
.apexcharts-datalabel-label,
.apexcharts-datalabel-value,
.apexcharts-datalabels,
.apexcharts-pie-label,
.apexcharts-pie-name-label,
.apexcharts-pie-name-label-group,
.apexcharts-pie-label-connector,
.apexcharts-unit-outer-label,
.apexcharts-unit-outer-label-group,
.apexcharts-unit-label-connector {
  cursor: default;
  pointer-events: none
}

.apexcharts-pie-label-connector,
.apexcharts-unit-label-connector {
  fill: none
}

.apexcharts-pie-label-delay,
.apexcharts-unit-label-delay {
  opacity: 0;
  animation-name: opaque;
  animation-duration: .3s;
  animation-fill-mode: forwards;
  animation-timing-function: ease
}

/* Slower than the pie's, on purpose: these come in while the dots are still
   easing into place, so a longer fade reads as arriving WITH the crowd. */
.apexcharts-unit-label-delay {
  animation-duration: .5s
}

.apexcharts-radialbar-label {
  cursor: pointer;
}

.apexcharts-annotation-rect,
.apexcharts-area-series .apexcharts-area,
.apexcharts-gridline,
.apexcharts-line,
.apexcharts-point-annotation-label,
.apexcharts-radar-series path:not(.apexcharts-marker),
.apexcharts-radar-series polygon,
.apexcharts-toolbar svg,
.apexcharts-tooltip .apexcharts-marker,
.apexcharts-xaxis-annotation-label,
.apexcharts-yaxis-annotation-label,
.apexcharts-zoom-rect,
.no-pointer-events {
  pointer-events: none
}

.apexcharts-tooltip-active .apexcharts-marker {
  transition: .15s ease all
}

.apexcharts-radar-series .apexcharts-yaxis {
  pointer-events: none;
}

.resize-triggers {
  animation: 1ms resizeanim;
  visibility: hidden;
  opacity: 0;
  height: 100%;
  width: 100%;
  overflow: hidden
}

.contract-trigger:before,
.resize-triggers,
.resize-triggers>div {
  content: " ";
  display: block;
  position: absolute;
  top: 0;
  left: 0
}

.resize-triggers>div {
  height: 100%;
  width: 100%;
  background: #eee;
  overflow: auto
}

.contract-trigger:before {
  overflow: hidden;
  width: 200%;
  height: 200%
}

.apexcharts-bar-goals-markers {
  pointer-events: none
}

.apexcharts-bar-shadows {
  pointer-events: none
}

.apexcharts-rangebar-goals-markers {
  pointer-events: none
}

.apexcharts-drilldown-target {
  cursor: pointer
}

.apexcharts-breadcrumb {
  position: absolute;
  z-index: 11;
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-size: 12px;
  font-family: inherit;
  padding: 2px 4px
}

.apexcharts-breadcrumb-item {
  background: transparent;
  border: none;
  padding: 2px 6px;
  border-radius: 3px;
  font: inherit;
  color: inherit;
  cursor: pointer;
  line-height: 1.2
}

.apexcharts-breadcrumb-item:hover:not(.apexcharts-breadcrumb-current) {
  background: rgba(0, 0, 0, 0.08)
}

.apexcharts-breadcrumb-arrow {
  margin-right: 4px;
  font-weight: 600;
  user-select: none
}

.apexcharts-breadcrumb-current {
  cursor: default;
  font-weight: 600;
  opacity: 0.85
}

.apexcharts-breadcrumb-separator {
  opacity: 0.5;
  user-select: none
}

.apexcharts-theme-dark .apexcharts-breadcrumb-item:hover:not(.apexcharts-breadcrumb-current) {
  background: rgba(255, 255, 255, 0.12)
}

.apexcharts-drilldown-loading {
  position: absolute;
  inset: 0;
  z-index: 12;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  font-size: 13px;
  font-family: inherit;
  color: inherit;
  background: rgba(255, 255, 255, 0.62);
  /* The chart underneath stays interactive-looking but must not take clicks
     while a level is resolving, or a second drill can start mid-fetch. */
  cursor: progress
}

.apexcharts-drilldown-loading-spinner {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  border: 2.5px solid rgba(0, 0, 0, 0.16);
  border-top-color: rgba(0, 0, 0, 0.55);
  animation: apexcharts-drilldown-spin 0.7s linear infinite
}

.apexcharts-drilldown-loading-text {
  opacity: 0.8
}

.apexcharts-theme-dark .apexcharts-drilldown-loading {
  background: rgba(30, 30, 30, 0.62)
}

.apexcharts-theme-dark .apexcharts-drilldown-loading-spinner {
  border-color: rgba(255, 255, 255, 0.22);
  border-top-color: rgba(255, 255, 255, 0.7)
}

@keyframes apexcharts-drilldown-spin {
  to {
    transform: rotate(360deg)
  }
}

@media (prefers-reduced-motion: reduce) {
  .apexcharts-drilldown-loading-spinner {
    animation: apexcharts-drilldown-pulse 1.4s ease-in-out infinite
  }

  @keyframes apexcharts-drilldown-pulse {
    0%, 100% {
      opacity: 0.35
    }

    50% {
      opacity: 1
    }
  }
}

.apexcharts-disable-transitions * {
  transition: none !important;
}
/* ── Trellis (#22): small multiples ─────────────────────────────────────── */
.apexcharts-trellis {
  position: relative;
}
.apexcharts-trellis-grid {
  display: grid;
}
.apexcharts-trellis-cell {
  min-width: 0;
  position: relative;
}
.apexcharts-trellis-header {
  font-size: 12px;
  font-weight: 600;
  line-height: 22px;
  height: 22px;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-title {
  font-size: 14px;
  font-weight: 700;
  padding: 2px 0 6px;
  color: var(--apx-fore, #373d3f);
}
/* Edge-label policy: a muted cell hides its axis-label INK, never the label
   SPACE — every panel keeps the identical plot rectangle, and flipping the
   policy on a resize is a class toggle, not a re-render. */
.apexcharts-trellis-mute-y .apexcharts-yaxis {
  opacity: 0;
}
.apexcharts-trellis-mute-x .apexcharts-xaxis {
  opacity: 0;
}
/* The shared toolbar floats at the top-right, so a grid that has one starts
   below it: from four columns on, the last cell's header (or a 2-D column
   strip label) would otherwise run under the buttons. One band for the whole
   grid, not per panel. */
.apexcharts-trellis-has-toolbar {
  padding-top: 24px;
}
/* 2-D faceting (P4): column labels once across the top, row labels once
   down the left. The row strip column is auto-sized; panel columns stay
   equal fractions, so panel alignment is independent of the strip width. */
.apexcharts-trellis-strip {
  font-size: 12px;
  font-weight: 600;
  color: var(--apx-fore, #373d3f);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.apexcharts-trellis-strip-column {
  text-align: center;
  line-height: 22px;
  height: 22px;
  align-self: end;
}
.apexcharts-trellis-strip-row {
  align-self: center;
  max-width: 140px;
  padding-right: 6px;
}
/* Empty (row, column) combinations. 'placeholder' keeps a REAL panel with a
   quiet label; 'skip' shows the tinted skeleton; 'hide' shows nothing while
   keeping the grid slot. */
.apexcharts-trellis-cell-empty {
  position: relative;
}
.apexcharts-trellis-empty-label {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: var(--apx-fore, #373d3f);
  opacity: 0.45;
  pointer-events: none;
}
.apexcharts-trellis-cell-hidden > * {
  visibility: hidden;
}
/* P5: one shared gradient strip is a heatmap grid's legend. The slot is
   content-sized inline (the strip svg's own box); centering is its own. */
.apexcharts-trellis-gradient-legend {
  margin: 10px auto 0;
}
/* Virtualization (P2): an unmounted panel's mount div reserves the exact
   panel height (inline min-height) so page height and scroll position never
   shift; the skeleton itself is a quiet tinted block. Deliberately not
   animated: a shimmering grid of 200 placeholders is noise. */
.apexcharts-trellis-panel.apexcharts-trellis-skeleton {
  background: var(--apx-fore, #373d3f);
  opacity: 0.05;
  border-radius: 4px;
}
/* tooltip: 'panel' — the group still syncs every panel's crosshair, but only
   the hovered cell shows its tooltip cards. */
.apexcharts-trellis[data-tooltip-mode='panel'] .apexcharts-trellis-cell:not(:hover) .apexcharts-tooltip,
.apexcharts-trellis[data-tooltip-mode='panel'] .apexcharts-trellis-cell:not(:hover) .apexcharts-xaxistooltip,
.apexcharts-trellis[data-tooltip-mode='panel'] .apexcharts-trellis-cell:not(:hover) .apexcharts-yaxistooltip {
  opacity: 0 !important;
}
/* tooltip: 'grid' (P3) — ALL per-panel tooltip ink is hidden (the group
   still computes it; the trellis card reads it) and one trellis-owned card
   follows the cursor with one row per panel. */
.apexcharts-trellis[data-tooltip-mode='grid'] .apexcharts-trellis-cell .apexcharts-tooltip,
.apexcharts-trellis[data-tooltip-mode='grid'] .apexcharts-trellis-cell .apexcharts-xaxistooltip,
.apexcharts-trellis[data-tooltip-mode='grid'] .apexcharts-trellis-cell .apexcharts-yaxistooltip {
  opacity: 0 !important;
}
.apexcharts-trellis-tooltip {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 14;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.1s ease;
  background: var(--apx-bg, #fff);
  color: var(--apx-fore, #373d3f);
  border: 1px solid rgba(120, 120, 120, 0.25);
  border-radius: 5px;
  box-shadow: 2px 2px 6px -4px rgba(0, 0, 0, 0.4);
  font-size: 12px;
  min-width: 140px;
  max-width: 320px;
}
.apexcharts-trellis-tooltip-active {
  opacity: 1;
}
.apexcharts-trellis-tooltip .apexcharts-tooltip-title {
  padding: 5px 10px;
  font-weight: 600;
  background: rgba(120, 120, 120, 0.08);
  border-bottom: 1px solid rgba(120, 120, 120, 0.18);
  margin-bottom: 2px;
}
.apexcharts-trellis-tooltip-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding: 2px 10px;
  line-height: 1.6;
}
.apexcharts-trellis-tooltip-row-active {
  background: rgba(120, 120, 120, 0.1);
  font-weight: 600;
}
.apexcharts-trellis-tooltip-key {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.apexcharts-trellis-tooltip-vals {
  display: flex;
  gap: 10px;
  white-space: nowrap;
}
.apexcharts-trellis-tooltip-val {
  display: inline-flex;
  align-items: center;
  gap: 5px;
}
.apexcharts-trellis-tooltip-marker {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
  flex: none;
}
/* Panel promotion (P3): the promoted cell spans the grid; the rest park.
   The promoted panel is the only visible one, so both its axes unmute. */
.apexcharts-trellis-cell-promoted {
  grid-column: 1 / -1;
}
.apexcharts-trellis-cell-parked {
  display: none;
}
.apexcharts-trellis-cell-promoted.apexcharts-trellis-mute-y .apexcharts-yaxis,
.apexcharts-trellis-cell-promoted.apexcharts-trellis-mute-x .apexcharts-xaxis {
  opacity: 1;
}
.apexcharts-trellis-header-clickable {
  cursor: pointer;
}
.apexcharts-trellis-header-clickable:hover {
  text-decoration: underline;
  text-underline-offset: 3px;
}
.apexcharts-trellis-breadcrumb {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  padding: 2px 0 6px;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-breadcrumb-back {
  border: none;
  background: none;
  padding: 0;
  font-size: 12px;
  cursor: pointer;
  color: var(--apx-accent, #008ffb);
}
.apexcharts-trellis-breadcrumb-back:hover {
  text-decoration: underline;
}
.apexcharts-trellis-breadcrumb-sep {
  opacity: 0.5;
}
.apexcharts-trellis-breadcrumb-current {
  font-weight: 600;
}
/* The toolbar download menu (P3). */
.apexcharts-trellis-menu {
  position: absolute;
  top: 26px;
  right: 0;
  display: none;
  flex-direction: column;
  min-width: 132px;
  background: var(--apx-bg, #fff);
  border: 1px solid rgba(120, 120, 120, 0.25);
  border-radius: 5px;
  box-shadow: 2px 2px 6px -4px rgba(0, 0, 0, 0.4);
  padding: 4px;
  z-index: 15;
}
.apexcharts-trellis-menu-open {
  display: flex;
}
.apexcharts-trellis-menu-item {
  border: none;
  background: none;
  text-align: left;
  font-size: 12px;
  padding: 5px 8px;
  border-radius: 3px;
  cursor: pointer;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-menu-item:hover {
  background: rgba(120, 120, 120, 0.12);
}
.apexcharts-trellis-toolbar {
  position: absolute;
  top: 0;
  right: 0;
  display: flex;
  gap: 2px;
  z-index: 12;
}
.apexcharts-trellis-tool {
  border: 0;
  background: transparent;
  padding: 2px;
  cursor: pointer;
  border-radius: 3px;
  color: #6e8192;
  line-height: 0;
}
.apexcharts-trellis-tool:hover {
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-tool.apexcharts-selected {
  color: var(--apx-accent, #008ffb);
}
.apexcharts-trellis-legend {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 4px 14px;
  padding: 8px 10px 2px;
}
.apexcharts-trellis-legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  line-height: 1;
}
.apexcharts-trellis-legend-item .apexcharts-legend-marker {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  display: inline-block;
}
.apexcharts-trellis-legend-item .apexcharts-legend-text {
  font-size: 12px;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-legend-item.apexcharts-inactive-legend {
  opacity: 0.45;
}

/* Printing (#3352). The sheet is narrower than the screen and nothing reports
   its width to the page, so a chart laid out for the screen would be cropped at
   the edge of the paper. The chart lays itself out again for print (see
   chart.print in the options); this caps whatever is left over so it shrinks to
   fit rather than being cut. Shrink only: a chart narrower than the page keeps
   the size it was drawn at. */
@media print {
  /* Scoped to the class the chart adds while it is laid out for the sheet: this
     pair of rules is only safe once an identity viewBox is in place, since
     without one a capped width crops the drawing instead of scaling it. A chart
     with chart.print.enabled:false gets neither, and prints as it always did. */
  .apexcharts-canvas.apexcharts-printing,
  .apexcharts-canvas.apexcharts-printing svg {
    max-width: 100% !important;
  }

  .apexcharts-canvas.apexcharts-printing svg {
    height: auto !important;
  }

  /* A scaled-down SVG is shorter than the box drawn for it, and the wrapper
     carries the pre-scale height inline, so without this a chart shrunk to fit a
     narrow column prints above a white gap the size of what it gave up. The
     host element's own inline min-height is cleared by _beforePrint. */
  .apexcharts-canvas.apexcharts-printing {
    height: auto !important;
  }

  .apexcharts-toolbar {
    display: none !important;
  }
}
`,Kn=globalThis.console;function qn(e,...t){Kn.error(e,...t)}function Jn(e){Kn.warn(e)}const Yn=`APEX-`,Xn=/* @__PURE__ */ new Date(`2027-07-31T00:00:00Z`),Zn=`__apex_license_v1__`;function Qn(){let e=globalThis,t=e[Zn];return t||(t={key:null,listeners:/* @__PURE__ */ new Set,result:null},e[Zn]=t),t}const l=class{static get licenseKey(){return Qn().key}static set licenseKey(e){Qn().key=e}static get listeners(){return Qn().listeners}static get validationResult(){return Qn().result}static set validationResult(e){Qn().result=e}static getKey(){return this.licenseKey}static getLicenseStatus(){return this.licenseKey?(this.validationResult=this.validateKey(this.licenseKey),this.validationResult):{expired:!1,signatureVerified:!1,valid:!1}}static isKeyValid(e){return!!e&&this.validateKey(e).valid}static isLicenseValid(){return this.getLicenseStatus().valid}static onChange(e){return this.listeners.add(e),()=>{this.listeners.delete(e)}}static setLicense(e){var t,n;if(!e)return this.licenseKey=null,void this.publish({expired:!1,signatureVerified:!1,valid:!1});let r=this.validateKey(e);r.valid||e===this.licenseKey||!((n=this.validationResult)!=null&&n.valid)?(this.licenseKey=e,this.publish(r),r.valid||qn(`[Apex] ${r.message}`)):Jn(`[Apex] Ignoring license key: ${(t=r.message)==null?`it is not valid`:t} A valid license is already active on this page.`)}static validateKey(e){let t=this.parseKey(e),n=this.validateStructure(e,t);if(!n.valid||!(t!=null&&t.signature))return n;let r=this.verdicts.get(e);return!1===r?{data:t.data,expired:!1,message:`Invalid license key. The license signature does not verify.`,signatureVerified:!0,valid:!1}:(r===void 0&&this.verifySignature(e,t,n),c(s({},n),{signatureVerified:!0===r}))}static _resetSignatureState(){this.verdicts.clear(),this.verifying.clear(),this.warnedUnverifiable=!1,this.epoch++}static base64ToBytes(e){let t=e.replace(/-/g,`+`).replace(/_/g,`/`),n=t.padEnd(4*Math.ceil(t.length/4),`=`),r=globalThis.atob;if(typeof r!=`function`)throw Error(`no base64 decoder available`);let i=r(n),a=new Uint8Array(i.length);for(let e=0;e<i.length;e++)a[e]=i.charCodeAt(e);return a}static canonicalPayload(e){let t=e.domains&&e.domains.length>0?e.domains.join(`,`):``;return`v1|${e.issueDate}|${e.expiryDate}|${e.plan}|${t}`}static notify(e){for(let t of this.listeners)try{t(e)}catch(e){}}static parseKey(e){if(typeof e!=`string`||!e.startsWith(Yn))return null;let t=e.slice(5);if(!t)return null;try{let e=new TextDecoder().decode(this.base64ToBytes(t)),n=JSON.parse(e);return n.issueDate&&n.expiryDate&&n.plan?{data:{domains:Array.isArray(n.domains)?n.domains:void 0,expiryDate:n.expiryDate,issueDate:n.issueDate,plan:n.plan,valid:!0},signature:typeof n.sig==`string`&&n.sig?n.sig:null}:null}catch(e){return null}}static publish(e){this.validationResult=e,this.notify(e)}static validateStructure(e,t){let n=e=>({expired:!1,message:e,signatureVerified:!1,valid:!1});if(typeof e!=`string`||!e.startsWith(Yn))return n(`Invalid license key format. License key must start with "APEX-".`);if(!t)return n(`Invalid license key. Unable to decode license data.`);let{data:r,signature:i}=t;if(!i&&/* @__PURE__ */ new Date>=Xn)return n(`This license key is in the old unsigned format, which is no longer accepted. Please request a replacement key.`);if(new Date(r.expiryDate)</* @__PURE__ */ new Date)return{data:r,expired:!0,message:`License expired on ${r.expiryDate}. Please renew your license.`,signatureVerified:!1,valid:!1};if(r.domains&&r.domains.length>0){let e=typeof location>`u`?``:location.hostname;if(!r.domains.some((t=>e===t||e.endsWith(`.${t}`))))return{data:r,expired:!1,message:`License is not valid for this domain (${e}). Allowed domains: ${r.domains.join(`, `)}.`,signatureVerified:!1,valid:!1}}return{data:r,expired:!1,signatureVerified:!1,valid:!0}}static verifySignature(e,t,n){return d(this,null,function*(){var r;if(this.verifying.has(e)||this.verdicts.has(e))return;this.verifying.add(e);let i=this.epoch,a=(r=globalThis.crypto)==null?void 0:r.subtle;if(!a||this.publicKeysSpki.length===0)return this.verifying.delete(e),void(this.warnedUnverifiable||(this.warnedUnverifiable=!0,Jn(a?`[Apex] No license signing key is configured in this build, so license signatures cannot be verified.`:`[Apex] Web Crypto is unavailable (a secure context is required), so the license signature cannot be verified.`)));let o=new TextEncoder().encode(this.canonicalPayload(t.data)),u=!1;for(let e of this.publicKeysSpki){try{let n=yield a.importKey(`spki`,this.base64ToBytes(e),{name:`ECDSA`,namedCurve:`P-256`},!1,[`verify`]);u=yield a.verify({hash:`SHA-256`,name:`ECDSA`},n,this.base64ToBytes(t.signature),o)}catch(e){u=!1}if(u)break}if(this.verifying.delete(e),this.epoch!==i)return;if(this.verdicts.set(e,u),u){let t=c(s({},n),{signatureVerified:!0});this.licenseKey===e?this.publish(t):this.notify(t);return}let d=`Invalid license key. The license signature does not verify.`,f={data:t.data,expired:!1,message:d,signatureVerified:!0,valid:!1};this.licenseKey===e?this.publish(f):this.notify(f),qn(`[Apex] ${d}`)})}};l.publicKeysSpki=[`MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEQIaK9UMD6n0oR/FIy8QdL0uSzKMQlf1BB+tOrji4/WuHsyRNxeDhVykoSsNURozMi1xhmqWvBH1L//xIfugTPA==`],l.verdicts=/* @__PURE__ */ new Map,l.verifying=/* @__PURE__ */ new Set,l.warnedUnverifiable=!1,l.epoch=0;let Q=l;const A=class{static applyStyles(e){Object.assign(e.style,this.CRITICAL_STYLES,{backgroundImage:this.createWatermarkPattern(),backgroundRepeat:`repeat`})}static node(e){return e?e.querySelector(`[${this.WATERMARK_ATTR}]`):null}static add(e,t){return e&&typeof document<`u`?(this.setManaged(e,t),this.paint(e)):null}static exists(e){return!!this.node(e)}static remove(e,t){e&&(this.setManaged(e,t),this.erase(e))}static untrack(e){this.managed.delete(e)}static createWatermarkPattern(){let e=this.WATERMARK_TEXT;return`url("data:image/svg+xml,${encodeURIComponent(`
      <svg xmlns="http://www.w3.org/2000/svg" width="300" height="200">
        <text
          x="50%"
          y="50%"
          dominant-baseline="middle"
          text-anchor="middle"
          font-family="-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Arial, sans-serif"
          font-size="18"
          font-weight="600"
          fill="rgba(134, 134, 134, 0.1)"
          transform="rotate(-35, 100, 60)"
        >${e}</text>
      </svg>
    `.trim())}")`}static erase(e){var t;(t=this.node(e))==null||t.remove()}static paint(e){let t=this.node(e);return t||(t=document.createElement(`div`),t.setAttribute(this.WATERMARK_ATTR,``),e.appendChild(t)),this.applyStyles(t),typeof getComputedStyle==`function`&&getComputedStyle(e).position===`static`&&(e.style.position=`relative`),t}static reconcile(){let e=Q.isLicenseValid();for(let t of this.managed)t.isConnected?e?this.erase(t):this.paint(t):this.managed.delete(t)}static setManaged(e,t){!1===(t==null?void 0:t.manage)?this.managed.delete(e):this.track(e)}static track(e){this.managed.add(e),this.subscribed||(this.subscribed=!0,Q.onChange((()=>{this.reconcile()})))}};A.WATERMARK_ATTR=`data-apexcharts-watermark`,A.WATERMARK_TEXT=`APEXCHARTS`,A.ATTR=`data-apexcharts-watermark`,A.CRITICAL_STYLES={bottom:`0`,display:`block`,left:`0`,msUserSelect:`none`,opacity:`1`,pointerEvents:`none`,position:`absolute`,right:`0`,top:`0`,userSelect:`none`,visibility:`visible`,webkitUserSelect:`none`,zIndex:`10000`},A.managed=/* @__PURE__ */ new Set,A.subscribed=!1;let $n=A;const er=`https://apexcharts.com/pricing`;let tr=!1;const $=/* @__PURE__ */ new Set;function nr(e){$.delete(e)}function rr(e,t){let n=e&&e.config&&e.config.chart||{},r=[];n.type===`unit`&&r.push(`unit`),n.requestedType===`raincloud`&&r.push(`raincloud`),t.trellis&&typeof t.trellis.isActive==`function`&&t.trellis.isActive()&&r.push(`trellis`),t.storyboard&&t.storyboard._used&&r.push(`storyboard`);let i=n.link;return t.linkedViews&&i&&(i.enabled===!0||typeof i.dimension==`function`)&&r.push(`link`),t.ink&&n.ink&&n.ink.enabled===!0&&r.push(`ink`),t.measure&&n.measure&&n.measure.enabled===!0&&r.push(`measure`),t.contextMenu&&n.contextMenu&&n.contextMenu.enabled===!0&&r.push(`context-menu`),t.perspectives&&t.perspectives._used&&r.push(`perspectives`),t.history&&n.history&&n.history.enabled===!0&&r.push(`history`),r}function ir(e){let t=e&&e.config&&e.config.chart&&e.config.chart.license;if(t)return t;let n=Q.getKey();if(n)return n;let r=Environment.getApex();return r&&r.license?r.license:null}const ar=/* @__PURE__ */ new Set([`premium`,`enterprise`]);function or(e){if(!e)return!1;let t=Q.validateKey(e);if(!t.valid)return!1;let n=t.data&&t.data.plan;return typeof n==`string`&&ar.has(n.toLowerCase())}function sr(e,t){let n=$n.add(t,{manage:!1});if(!n||typeof MutationObserver>`u`||e._wmNodeObserver&&e._wmObservedNode===n)return;e._wmNodeObserver&&e._wmNodeObserver.disconnect();let r=new MutationObserver(()=>{let e=$n.node(t);e&&(r.disconnect(),$n.applyStyles(e),r.takeRecords(),r.observe(e,{attributes:!0,attributeFilter:[`style`]}))});r.observe(n,{attributes:!0,attributeFilter:[`style`]}),e._wmNodeObserver=r,e._wmObservedNode=n}function cr(e,t){if(sr(e,t),typeof MutationObserver>`u`||e._wmWrapObserver)return;let n=new MutationObserver(()=>{$n.node(t)||sr(e,t)});n.observe(t,{childList:!0}),e._wmWrapObserver=n}function lr(e,t){e._wmWrapObserver&&(e._wmWrapObserver.disconnect(),e._wmWrapObserver=null),e._wmNodeObserver&&(e._wmNodeObserver.disconnect(),e._wmNodeObserver=null),e._wmObservedNode=null;let n=t||e.w&&e.w.dom&&e.w.dom.elWrap;n&&$n.remove(n,{manage:!1})}function ur(e,t,n){if(e._premiumLicenseNotified)return;e._premiumLicenseNotified=!0;let r=n.length>1;if(!t){console.warn(`[ApexCharts] Premium feature${r?`s`:``} in use (${n.join(`, `)}) without a license. Running in trial mode with a watermark. Get a license: ${er}`);return}let i=Q.validateKey(t);if(i.valid){let e=i.data&&i.data.plan||`current`;console.warn(`[ApexCharts] Premium feature${r?`s`:``} in use (${n.join(`, `)}) require a Premium or Enterprise license; the ${e} plan does not include ${r?`them`:`it`}. Running in trial mode with a watermark. Upgrade: ${er}`);return}t!==Q.getKey()&&console.error(`[Apex] ${i.message}`)}function dr(e,t){try{if(!Environment.isBrowser())return;if(e&&e.globals&&e.globals.isDestroyed){$.delete(t);return}let n=e&&e.dom&&e.dom.elWrap;if(!n)return;let r=rr(e,t);if(r.length===0){$.delete(t),lr(t,n);return}$.add(t);let i=ir(e);if(or(i)){lr(t,n);return}cr(t,n),ur(t,i,r)}catch(e){}}function fr(){if(!Environment.isBrowser())return;let e=/* @__PURE__ */ new Set,t=Environment.getApex(),n=t&&t._chartInstances;Array.isArray(n)&&n.forEach(t=>{let n=t&&t.chart;n&&n.w&&!n.w.globals.isDestroyed&&(e.add(n),dr(n.w,n))}),Array.from($).forEach(t=>{let n=t&&t.w,r=n&&n.dom&&n.dom.elWrap;if(!n||n.globals.isDestroyed||!r||r.isConnected===!1){$.delete(t);return}e.has(t)||dr(n,t)})}Q.onChange(fr);const pr=class _ApexCharts{constructor(e,t){u(this,`core`),u(this,`responsive`),u(this,`axes`),u(this,`grid`),u(this,`graphics`),u(this,`coreUtils`),u(this,`crosshairs`),u(this,`events`),u(this,`fill`),u(this,`localization`),u(this,`options`),u(this,`series`),u(this,`theme`),u(this,`formatters`),u(this,`titleSubtitle`),u(this,`dimensions`),u(this,`updateHelpers`),u(this,`tooltip`),u(this,`data`),u(this,`animations`),u(this,`exports`),u(this,`legend`),u(this,`toolbar`),u(this,`zoomPanSelection`),u(this,`keyboardNavigation`),u(this,`annotations`),u(this,`morphTypeChange`),u(this,`timeScale`),u(this,`_keyboardNavigation`),u(this,`_zoomPanSelection`),u(this,`windowResizeHandler`),u(this,`parentResizeHandler`),u(this,`publicMethods`,[]),u(this,`eventList`,[]),u(this,`_renderPromise`,null),u(this,`_parentResizeWaiter`,null),u(this,`_printRestore`,null),u(this,`beforePrintHandler`),u(this,`afterPrintHandler`),u(this,`config`),u(this,`perspectives`),u(this,`storyboard`),u(this,`history`),u(this,`linkedViews`),u(this,`trellis`),u(this,`ink`),u(this,`measure`),u(this,`contextMenu`),u(this,`weave`),u(this,`waterfall`),u(this,`streamgraph`),u(this,`renderer`),u(this,`rendererController`),this.opts=t,this.ctx=this,this.w=new Base(t).init(),this.el=e,this.w.globals.cuid=_.randomId(),this.w.globals.chartID=this.w.config.chart.id?_.escapeString(this.w.config.chart.id):this.w.globals.cuid,we(this.w),new InitCtxVariables(this).initModules(),this.lastUpdateOptions=null,this._updateStats={fast:0,fastWithAxes:0,full:0},this.create=this.create.bind(this),Environment.isBrowser()&&(this.windowResizeHandler=this._windowResizeHandler.bind(this),this.parentResizeHandler=this._parentResizeCallback.bind(this),this.beforePrintHandler=this._beforePrint.bind(this),this.afterPrintHandler=this._afterPrint.bind(this))}render(){var e,t;if(!((t=(e=this.w)==null?void 0:e.config)!=null&&t.chart))return Promise.reject(/* @__PURE__ */ Error("ApexCharts: chart configuration is missing or invalid. Ensure the options object includes a `chart` property."));if(this._renderPromise)return this._renderPromise;let n=new Promise((e,t)=>{var n,r,i,a,o,s,c,u,d,f,p,m,h;if(_.elementExists(this.el)){Apex._chartInstances===void 0&&(Apex._chartInstances=[]),this.w.config.chart.id&&Apex._chartInstances.push({id:this.w.globals.chartID,group:this.w.config.chart.group,chart:this}),this.setLocale(this.w.config.chart.defaultLocale);let g=this.w.config.chart.events.beforeMount;typeof g==`function`&&g(this,this.w),this.events.fireEvent(`beforeMount`,[this,this.w]);let v=this.w.config.trellis,y=!!(v&&(v.by||v.row||v.column)),b=!!(y&&this.trellis&&this.trellis.isActive());if(y&&!this.trellis&&console.warn("ApexCharts: `trellis` requires the trellis feature, which is not in the default bundle. Bundler: import 'apexcharts/features/trellis'. Script tag: add <script src='.../dist/features/trellis.js'> after apexcharts.js. Rendering as a single chart."),(r=(n=this.w.config.chart)==null?void 0:n.measure)!=null&&r.enabled&&!this.measure&&console.warn("ApexCharts: `chart.measure` requires the measure feature, which is not in the default bundle. Bundler: import 'apexcharts/features/measure'. Script tag: add <script src='.../dist/features/measure.js'> after apexcharts.js."),(a=(i=this.w.config.chart)==null?void 0:i.link)!=null&&a.enabled&&!this.linkedViews&&console.warn("ApexCharts: `chart.link` requires the link feature, which is not in the default bundle. Bundler: import 'apexcharts/features/link'. Script tag: add <script src='.../dist/features/link.js'> after apexcharts.js."),!this.ink){let e=(s=(o=this.w.config.chart)==null?void 0:o.ink)==null?void 0:s.enabled,t=((u=(c=this.w.config.annotations)==null?void 0:c.points)==null?[]:u).some(e=>e&&e.draggable);(e||t)&&console.warn("ApexCharts: `chart.ink` / `annotations.points[].draggable` requires the ink feature, which is not in the default bundle. Bundler: import 'apexcharts/features/ink'. Script tag: add <script src='.../dist/features/ink.js'> after apexcharts.js.")}if((f=(d=this.w.config.chart)==null?void 0:d.contextMenu)!=null&&f.enabled&&!this.contextMenu&&console.warn("ApexCharts: `chart.contextMenu` requires the context-menu feature, which is not in the default bundle. Bundler: import 'apexcharts/features/context-menu'. Script tag: add <script src='.../dist/features/context-menu.js'> after apexcharts.js."),(m=(p=this.w.config.chart)==null?void 0:p.history)!=null&&m.enabled&&!this.history&&console.warn("ApexCharts: `chart.history` requires the history feature, which is not in the default bundle. Bundler: import 'apexcharts/features/history'. Script tag: add <script src='.../dist/features/history.js'> after apexcharts.js."),Environment.isBrowser()){b||(window.addEventListener(`resize`,this.windowResizeHandler),Un(this.el.parentNode,this.parentResizeHandler),this._printEnabled()&&(window.addEventListener(`beforeprint`,this.beforePrintHandler),window.addEventListener(`afterprint`,this.afterPrintHandler)));let e=this.el.getRootNode&&this.el.getRootNode(),t=_.is(`ShadowRoot`,e),n=this.el.ownerDocument,r=t?e.getElementById(`apexcharts-css`):n.getElementById(`apexcharts-css`);if(!r){r=BrowserAPIs.createElementNS(`http://www.w3.org/1999/xhtml`,`style`),r.id=`apexcharts-css`,r.textContent=`@keyframes opaque {
  0% {
    opacity: 0
  }

  to {
    opacity: 1
  }
}

@keyframes resizeanim {

  0%,
  to {
    opacity: 0
  }
}

.apexcharts-canvas {
  position: relative;
  direction: ltr !important;
  user-select: none;
  /* Focus indicator colour. Themes override below. */
  --apexcharts-focus-color: #008FFB;
}

/* Dark theme & high-contrast: brighter focus colour for sufficient contrast. */
.apexcharts-canvas .apexcharts-theme-dark,
.apexcharts-theme-dark.apexcharts-canvas {
  --apexcharts-focus-color: #FFD500;
}
.apexcharts-canvas.apexcharts-high-contrast,
.apexcharts-high-contrast.apexcharts-canvas {
  --apexcharts-focus-color: #FFFF00;
}

/* Visually-hidden aria-live status region (WCAG 4.1.3 Status Messages). */
.apexcharts-sr-status {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* Respect OS-level reduced-motion preference (WCAG 2.3.3). */
@media (prefers-reduced-motion: reduce) {
  .apexcharts-canvas *,
  .apexcharts-canvas *::before,
  .apexcharts-canvas *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

.apexcharts-canvas ::-webkit-scrollbar {
  -webkit-appearance: none;
  width: 6px
}

.apexcharts-canvas ::-webkit-scrollbar-thumb {
  border-radius: 4px;
  background-color: rgba(0, 0, 0, .5);
  box-shadow: 0 0 1px rgba(255, 255, 255, .5);
  -webkit-box-shadow: 0 0 1px rgba(255, 255, 255, .5)
}

.apexcharts-inner {
  position: relative
}

.apexcharts-text tspan {
  font-family: inherit
}

rect.legend-mouseover-inactive,
.legend-mouseover-inactive rect,
.legend-mouseover-inactive path,
.legend-mouseover-inactive circle,
.legend-mouseover-inactive line,
.legend-mouseover-inactive text.apexcharts-yaxis-title-text,
.legend-mouseover-inactive text.apexcharts-yaxis-label {
  transition: .15s ease all;
  opacity: .2
}

/* Linked Views (#4): per-mark crossfilter dim. Applied to individual data
   marks (not whole series) whose x is outside the brushed range. Opacity is
   overridable per chart via the --apx-cf-dim custom property. */
.apexcharts-crossfilter-dimmed {
  transition: opacity .25s ease;
  opacity: var(--apx-cf-dim, .2)
}

/* Linked Views (#4): default styling for the built-in crossfilter data table
   (cf.dataTable). Deliberately light so host styles can override. */
.apexcharts-cf-table {
  border-collapse: collapse;
  width: 100%;
  font-size: 13px;
}
.apexcharts-cf-table caption {
  caption-side: bottom;
  text-align: right;
  padding: 6px 2px;
  font-size: 12px;
  opacity: .7
}
.apexcharts-cf-table th,
.apexcharts-cf-table td {
  padding: 6px 10px;
  text-align: left;
  border-bottom: 1px solid rgba(0, 0, 0, .08)
}
.apexcharts-cf-table th {
  font-weight: 600;
  border-bottom-width: 2px
}
.apexcharts-cf-table tbody tr:hover {
  background: rgba(99, 102, 241, .06)
}

/* Measure ruler (#18): measure / delta ruler.
   Theme via these classes or the --apx-measure-* custom properties below
   (config \`chart.measure.colors\` overrides both). The ruler group also carries
   a direction class: apexcharts-measure-up | -down | -flat.
   Element classes:
     .apexcharts-measure-band     shaded span band
     .apexcharts-measure-vline    vertical guide lines
     .apexcharts-measure-line     free-mode diagonal line
     .apexcharts-measure-label-bg readout box     .apexcharts-measure-label text
   Colors are applied as SVG presentation attributes, so any rule you write on
   these classes overrides them. */
.apexcharts-canvas {
  --apx-measure-up: #16a34a;
  --apx-measure-down: #dc2626;
  --apx-measure-neutral: #64748b;
  --apx-measure-guide: #94a3b8;
}
.apexcharts-measure-capture {
  cursor: crosshair;
}

/* Radial Actions (#chrome): right-click context menu. Theme via these classes
   or the --apx-menu-* custom properties. */
.apexcharts-canvas {
  --apx-menu-bg: #ffffff;
  --apx-menu-fg: #1e293b;
  --apx-menu-border: #e2e8f0;
  --apx-menu-hover: #f1f5f9;
  --apx-menu-shadow: rgba(15, 23, 42, 0.18);
}
.apexcharts-context-menu {
  min-width: 168px;
  padding: 4px;
  border-radius: 8px;
  background: var(--apx-menu-bg);
  border: 1px solid var(--apx-menu-border);
  box-shadow: 0 6px 22px var(--apx-menu-shadow);
  font-family: Helvetica, Arial, sans-serif;
  font-size: 13px;
  z-index: 20;
  user-select: none;
}
.apexcharts-context-menu-item {
  display: block;
  width: 100%;
  box-sizing: border-box;
  text-align: left;
  padding: 7px 12px;
  border: 0;
  border-radius: 5px;
  background: transparent;
  color: var(--apx-menu-fg);
  font: inherit;
  cursor: pointer;
}
.apexcharts-context-menu-item:hover,
.apexcharts-context-menu-item--active {
  background: var(--apx-menu-hover);
}
.apexcharts-context-menu-item:focus {
  outline: none;
}

/* Ink Layer (#7): the floating note editor card, opened by clicking an
   ink-managed annotation. Theme via these classes or the --apx-ink-* vars. */
.apexcharts-canvas {
  --apx-ink-card-bg: #ffffff;
  --apx-ink-card-fg: #1e293b;
  --apx-ink-card-border: #e2e8f0;
  --apx-ink-card-hover: #f1f5f9;
  --apx-ink-card-accent: #6366f1;
  --apx-ink-card-shadow: rgba(15, 23, 42, 0.18);
}
.apexcharts-ink-card {
  position: absolute;
  z-index: 25;
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 8px;
  border-radius: 8px;
  background: var(--apx-ink-card-bg);
  border: 1px solid var(--apx-ink-card-border);
  box-shadow: 0 6px 22px var(--apx-ink-card-shadow);
  font-family: Helvetica, Arial, sans-serif;
  font-size: 12px;
  color: var(--apx-ink-card-fg);
  user-select: none;
}
.apexcharts-ink-card-row {
  display: flex;
  align-items: center;
  gap: 4px;
}
.apexcharts-ink-card input.apexcharts-ink-editor {
  flex: 1 1 auto;
  width: 150px;
  min-width: 0;
  box-sizing: border-box;
  padding: 4px 6px;
  font: inherit;
  color: inherit;
  background: transparent;
  border: 1px solid var(--apx-ink-card-border);
  border-radius: 5px;
}
.apexcharts-ink-card input.apexcharts-ink-editor:focus {
  outline: none;
  border-color: var(--apx-ink-card-accent);
}
.apexcharts-ink-btn {
  flex: 0 0 auto;
  width: 24px;
  height: 24px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  border: 0;
  border-radius: 5px;
  background: transparent;
  color: inherit;
  font: inherit;
  font-size: 12px;
  line-height: 1;
  cursor: pointer;
}
.apexcharts-ink-btn:hover,
.apexcharts-ink-btn--active {
  background: var(--apx-ink-card-hover);
}
.apexcharts-ink-btn:focus-visible,
.apexcharts-ink-swatch:focus-visible {
  outline: 2px solid var(--apx-ink-card-accent);
  outline-offset: 1px;
}
.apexcharts-ink-btn--bold {
  font-weight: 700;
}
.apexcharts-ink-btn--delete:hover {
  color: #dc2626;
}
.apexcharts-ink-swatch {
  flex: 0 0 auto;
  width: 16px;
  height: 16px;
  padding: 0;
  border: 1px solid rgba(100, 116, 139, 0.45);
  border-radius: 50%;
  cursor: pointer;
}
.apexcharts-ink-swatch--active {
  box-shadow:
    0 0 0 2px var(--apx-ink-card-bg),
    0 0 0 4px var(--apx-ink-card-accent);
}
.apexcharts-ink-sep {
  flex: 0 0 auto;
  width: 1px;
  height: 16px;
  margin: 0 2px;
  background: var(--apx-ink-card-border);
}
.apexcharts-ink-cardlabel {
  flex: 0 0 auto;
  font-size: 10px;
  letter-spacing: 0.4px;
  text-transform: uppercase;
  opacity: 0.65;
  margin-right: 2px;
}
.apexcharts-ink-marker-size {
  flex: 0 0 auto;
  min-width: 16px;
  text-align: center;
  font-variant-numeric: tabular-nums;
}

.apexcharts-legend-text {
  padding-left: 15px;
  margin-left: -15px;
}

.apexcharts-legend-series[role="button"]:focus {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: 2px;
}

.apexcharts-legend-series[role="button"]:focus:not(:focus-visible) {
  outline: none;
}

.apexcharts-legend-series[role="button"]:focus-visible {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: 2px;
}

.apexcharts-series-collapsed {
  opacity: 0
}

/* A series still playing its exit tween stays painted so it can visibly shrink
   away, hiding it on the first frame leaves a hole in a stacked chart for the
   length of the animation. Dropped once the tween lands. */
.apexcharts-series-collapsed.apexcharts-series-collapsing {
  opacity: 1
}

/* Its labels ride the shrinking marks, but a mark runs out of room for its text
   well before it reaches zero, so fade them across the exit instead of holding
   them crisp over a sliver. Duration is set inline from dynamicAnimation.speed. */
.apexcharts-datalabels.apexcharts-series-collapsing {
  animation: apexcharts-datalabels-exit var(--apexcharts-dl-exit, 400ms) ease-in
    forwards;
}

@keyframes apexcharts-datalabels-exit {
  from {
    opacity: 1
  }
  to {
    opacity: 0
  }
}

.apexcharts-canvas svg:focus:not(:focus-visible) {
  outline: none;
}

/* Keyboard navigation focus indicator on SVG data elements.
   SVG elements don't support CSS outline, so we use stroke. */
.apexcharts-bar-area.apexcharts-keyboard-focused,
.apexcharts-candlestick-area.apexcharts-keyboard-focused,
.apexcharts-boxPlot-area.apexcharts-keyboard-focused,
.apexcharts-rangebar-area.apexcharts-keyboard-focused,
.apexcharts-pie-area.apexcharts-keyboard-focused,
.apexcharts-heatmap-rect.apexcharts-keyboard-focused,
.apexcharts-treemap-rect.apexcharts-keyboard-focused {
  stroke: var(--apexcharts-focus-color, #008FFB);
  stroke-width: 2;
  stroke-opacity: 1;
}

.apexcharts-tooltip {
  --apx-tt-bg: #ffffff;
  /* Shared by the body and the arrow's two outward facets, so the
   * hairline reads as one continuous outline around the whole shape.
   * Keep it strong enough to survive on its own: the shadow below is
   * elevation, not edge definition. */
  --apx-tt-border: rgba(15, 23, 42, 0.12);
  /* Elevation, in three layers: a tight contact shadow that anchors the
   * bottom edge, a directional key shadow for the lift, and a wide
   * ambient one that grounds the whole box. Each is weaker and more
   * diffuse than the last.
   *
   * A tooltip is unusual in that it floats over *data*, so reach costs
   * more than it does on a page: every pixel the shadow travels tints a
   * bar or a line the reader is trying to compare. These numbers are
   * tuned to keep the near-edge contrast that reads as elevation while
   * dropping the long low haze that only muddies the plot.
   *
   * Note there is deliberately no \`0 0 0 1px\` ring layer. That used to
   * stand in for edge definition back when --apx-tt-border was barely
   * visible; now that the border is a real hairline (and the arrow
   * shares it) a ring only double-draws the outline, and being spread
   * rather than offset it leaked ink upward too, flattening the lift.
   *
   * \`--apx-tt-shadow-dir\` flips the whole stack's Y in one place — see
   * the \`[data-placement="bottom"]\` rule further down. */
  --apx-tt-shadow-dir: 1;
  --apx-tt-shadow: 0 calc(var(--apx-tt-shadow-dir) * 1px) 2px rgba(15, 23, 42, 0.06), 0 calc(var(--apx-tt-shadow-dir) * 4px) 8px -2px rgba(15, 23, 42, 0.10), 0 calc(var(--apx-tt-shadow-dir) * 12px) 20px -8px rgba(15, 23, 42, 0.14);
  --apx-tt-arrow-bg: var(--apx-tt-bg);
  --apx-tt-color: #0f172a;
  --apx-tt-color-muted: rgba(15, 23, 42, 0.55);
  border-radius: 8px;
  background: var(--apx-tt-bg);
  border: 1px solid var(--apx-tt-border);
  box-shadow: var(--apx-tt-shadow);
  color: var(--apx-tt-color);
  cursor: default;
  font-size: 13px;
  left: 0;
  top: 0;
  opacity: 0;
  pointer-events: none;
  position: absolute;
  display: flex;
  flex-direction: column;
  padding: 2px 0;
  white-space: nowrap;
  z-index: 12;
  transition: opacity .12s ease
}

/* While the tooltip is visible, smoothly animate position changes
 * between data points. Kept short (160 ms) and ease-out so it stays
 * responsive — too long would feel laggy when sweeping across many
 * points fast. The position transition is only attached after the
 * first paint (Position.applyTooltipPosition flips \`data-positioned\`
 * once the tooltip has been placed) so the *first* show doesn't slide
 * the tooltip in from the previously-stale (0,0) coordinates. */
.apexcharts-tooltip.apexcharts-active {
  opacity: 1;
  transition: opacity .12s ease
}
.apexcharts-tooltip.apexcharts-active[data-positioned="true"] {
  transition: opacity .12s ease, left .16s ease-out, top .16s ease-out
}

.apexcharts-tooltip.apexcharts-theme-light {
  /* defaults already set above; class kept for backward-compat selectors */
}

.apexcharts-tooltip.apexcharts-theme-dark {
  --apx-tt-bg: #1c1c1f;
  --apx-tt-border: rgba(255, 255, 255, 0.16);
  /* Dark needs more alpha than light to register at all, but not as much
   * as it used to: the light rim above now carries the edge, so the
   * shadow is free to be pure elevation instead of doubling as an
   * outline. Same geometry as light, heavier ink. */
  --apx-tt-shadow: 0 calc(var(--apx-tt-shadow-dir) * 1px) 2px rgba(0, 0, 0, 0.24), 0 calc(var(--apx-tt-shadow-dir) * 4px) 8px -2px rgba(0, 0, 0, 0.30), 0 calc(var(--apx-tt-shadow-dir) * 12px) 20px -8px rgba(0, 0, 0, 0.38);
  --apx-tt-color: #f3f4f6;
  --apx-tt-color-muted: rgba(243, 244, 246, 0.55);
}

.apexcharts-tooltip * {
  font-family: inherit
}

/* Point-annotation hover tooltip (apexcharts/apexcharts.js#2424). Reuses the
 * glass body/border/shadow from \`.apexcharts-tooltip\` but holds free-form
 * content, so it needs its own padding, wrapping and a sane max width. */
.apexcharts-tooltip.apexcharts-annotation-tooltip {
  padding: 6px 10px;
  max-width: 240px;
  white-space: normal;
  line-height: 1.4;
  pointer-events: none;
  z-index: 13
}

.apexcharts-tooltip-title {
  padding: 8px 12px 4px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.01em;
  color: var(--apx-tt-color-muted);
  background: transparent;
  border-bottom: none;
  margin-bottom: 0
}

.apexcharts-tooltip.apexcharts-theme-light .apexcharts-tooltip-title,
.apexcharts-tooltip.apexcharts-theme-dark .apexcharts-tooltip-title {
  background: transparent;
  border-bottom: none
}

/* \`fillSeriesColor\`: each series-group already paints itself with the
 * series colour. Drop the glass body entirely (transparent bg, no
 * border, no backdrop-filter, no padding) and clip the coloured
 * series-group(s) to the tooltip's rounded corners so they fill the
 * shell edge-to-edge. Text inside the coloured group is forced to
 * white for contrast. */
.apexcharts-tooltip.apexcharts-tooltip-fill-series {
  background: transparent;
  -webkit-backdrop-filter: none;
  backdrop-filter: none;
  border: none;
  padding: 0;
  overflow: hidden;
  color: #fff
}

.apexcharts-tooltip.apexcharts-tooltip-fill-series .apexcharts-tooltip-title {
  background: rgba(0, 0, 0, 0.22);
  color: #fff;
  opacity: 1;
  padding: 6px 12px
}

.apexcharts-tooltip.apexcharts-tooltip-fill-series .apexcharts-tooltip-series-group {
  color: #fff
}

/* Arrow connector — a 45°-rotated square straddling the body's edge, so
 * the body's 1px border runs continuously out across the arrow and back.
 * The two facets that face away from the tooltip carry the border; the
 * two that face into it carry none, and the square's opaque fill covers
 * the segment of the body's own border it sits on, hiding the seam.
 *
 * This is why it's a rotated square and not a triangle: \`clip-path\`
 * erases \`border\` and \`box-shadow\` along with everything outside the
 * polygon, which left \`filter: drop-shadow\` as the only way to suggest
 * an edge — and a drop-shadow can only ever blur one, never draw a
 * hairline. Nothing here needs a filter.
 *
 * Geometry: a square of side S rotated 45° reaches S/√2 from its centre
 * to each corner, so S = 10px gives the ~7px tip overhang that
 * ARROW_TIP_OVERHANG assumes (tooltip/constants.js) over a ~14px base.
 * The offsets park the square's *centre* 1px outside the padding box
 * (-6px = -1px border - 10px/2), i.e. exactly on the body's border line,
 * so the two borders meet end to end instead of overlapping or gapping.
 * \`box-sizing\` must be border-box or the bordered sides would grow the
 * square asymmetrically and knock its centre off that line. */
.apexcharts-tooltip-arrow {
  position: absolute;
  box-sizing: border-box;
  width: 10px;
  height: 10px;
  background: var(--apx-tt-arrow-bg);
  transform: rotate(45deg);
  pointer-events: none;
  top: calc(var(--apx-tt-arrow-y, 50%) - 5px)
}

/* Which two sides face outward depends on the placement. Under
 * \`rotate(45deg)\` the square's bottom-left corner swings to the left,
 * top-right to the right, top-left to the top and bottom-right to the
 * bottom — so the pair of borders below is always the two sharing the
 * corner that ends up as the tip. */
.apexcharts-tooltip[data-placement="right"] .apexcharts-tooltip-arrow {
  left: -6px;
  border-left: 1px solid var(--apx-tt-border);
  border-bottom: 1px solid var(--apx-tt-border)
}

.apexcharts-tooltip[data-placement="left"] .apexcharts-tooltip-arrow {
  right: -6px;
  border-top: 1px solid var(--apx-tt-border);
  border-right: 1px solid var(--apx-tt-border)
}

/* Vertical arrow variants: tooltip is above/below the data point and the
 * arrow points down/up. The base rule above uses \`--apx-tt-arrow-y\` for
 * left/right placement; for top/bottom we centre on \`--apx-tt-arrow-x\`
 * instead (set by applyTooltipPosition). */
.apexcharts-tooltip[data-placement="top"] .apexcharts-tooltip-arrow,
.apexcharts-tooltip[data-placement="bottom"] .apexcharts-tooltip-arrow {
  top: auto;
  left: calc(var(--apx-tt-arrow-x, 50%) - 5px)
}

.apexcharts-tooltip[data-placement="top"] .apexcharts-tooltip-arrow {
  bottom: -6px;
  border-right: 1px solid var(--apx-tt-border);
  border-bottom: 1px solid var(--apx-tt-border)
}

.apexcharts-tooltip[data-placement="bottom"] .apexcharts-tooltip-arrow {
  top: -6px;
  border-top: 1px solid var(--apx-tt-border);
  border-left: 1px solid var(--apx-tt-border)
}

/* When the tooltip is flipped below the data point, the default
 * downward-biased shadow leaves its top edge undefined. Negating the
 * direction casts the whole elevation upward instead, so the shadow
 * falls between the tooltip and the mark above it. One multiplier flips
 * all three layers together; the arrow needs no counterpart, since its
 * border doesn't depend on light direction. */
.apexcharts-tooltip[data-placement="bottom"] {
  --apx-tt-shadow-dir: -1
}

.apexcharts-tooltip-text-goals-value,
.apexcharts-tooltip-text-y-value,
.apexcharts-tooltip-text-z-value {
  display: inline-block;
  margin-left: 5px;
  font-weight: 600
}

.apexcharts-tooltip-text-goals-label:empty,
.apexcharts-tooltip-text-goals-value:empty,
.apexcharts-tooltip-text-y-label:empty,
.apexcharts-tooltip-text-y-value:empty,
.apexcharts-tooltip-text-z-value:empty,
.apexcharts-tooltip-title:empty {
  display: none
}

.apexcharts-tooltip-text-goals-label,
.apexcharts-tooltip-text-goals-value {
  padding: 6px 0 5px
}

.apexcharts-tooltip-goals-group,
.apexcharts-tooltip-text-goals-label,
.apexcharts-tooltip-text-goals-value {
  display: flex
}

.apexcharts-tooltip-text-goals-label:not(:empty),
.apexcharts-tooltip-text-goals-value:not(:empty) {
  margin-top: -6px
}

.apexcharts-tooltip-marker {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  position: relative;
  width: 12px;
  height: 12px;
  margin-right: 6px;
  vertical-align: middle;
  color: inherit;
}

.apexcharts-tooltip-marker svg {
  width: 100%;
  height: 100%;
  display: block;
}

.apexcharts-tooltip-series-group {
  padding: 4px 12px;
  display: none;
  gap: 8px;
  text-align: left;
  justify-content: left;
  align-items: center
}

.apexcharts-tooltip-series-group.apexcharts-active .apexcharts-tooltip-marker {
  opacity: 1
}

.apexcharts-tooltip-series-group.apexcharts-active:last-child,
.apexcharts-tooltip-series-group:last-child {
  padding-bottom: 8px
}

.apexcharts-tooltip-y-group {
  padding: 6px 0 5px
}

/* \`tooltip.compact\`: a tight box instead of a card, for panels a normal card
   would cover (small multiples, sparklines, tiles). Only the box shrinks, so
   the arrow and every anchor rule still apply. Rows stay stacked when there
   are several series (the names are what tells them apart); a one-series
   chart collapses to a single line, see \`-value-only\` below. */
.apexcharts-tooltip.apexcharts-tooltip-compact {
  padding: 3px 8px;
  font-size: 11px;
  line-height: 1.35
}

.apexcharts-tooltip-compact .apexcharts-tooltip-title {
  padding: 0;
  font-size: 11px;
  white-space: nowrap
}

.apexcharts-tooltip-compact .apexcharts-tooltip-series-group,
.apexcharts-tooltip-compact .apexcharts-tooltip-series-group.apexcharts-active:last-child,
.apexcharts-tooltip-compact .apexcharts-tooltip-series-group:last-child {
  padding: 0;
  gap: 5px
}

.apexcharts-tooltip-compact .apexcharts-tooltip-y-group {
  padding: 0
}

.apexcharts-tooltip-compact .apexcharts-tooltip-marker {
  width: 8px;
  height: 8px
}

/* A one-series panel: the series name repeats what the panel header already
   says, so the value stands alone and the x label becomes its prefix on one
   line ("Aug 2024  6.59"). */
.apexcharts-tooltip.apexcharts-tooltip-compact.apexcharts-tooltip-value-only {
  /* The tooltip body is a flex COLUMN by default (title row, then series
     rows); one series needs no column, so the same box turns into one line. */
  flex-direction: row;
  align-items: baseline;
  gap: 6px
}

.apexcharts-tooltip-value-only .apexcharts-tooltip-marker {
  display: none
}

.apexcharts-tooltip-value-only .apexcharts-tooltip-text-y-label {
  display: none
}

.apexcharts-custom-tooltip,
.apexcharts-tooltip-box {
  padding: 4px 8px
}

.apexcharts-tooltip-boxPlot {
  display: flex;
  flex-direction: column-reverse
}

.apexcharts-tooltip-box>div {
  margin: 4px 0
}

.apexcharts-tooltip-box span.value {
  font-weight: 700
}

.apexcharts-tooltip-rangebar {
  padding: 5px 8px
}

.apexcharts-tooltip-rangebar .category {
  font-weight: 600;
  color: #777
}

.apexcharts-tooltip-rangebar .series-name {
  font-weight: 700;
  display: block;
  margin-bottom: 5px
}

/* Streamgraph: every band read out at one column, top-down in stacking order.
 * A row per band rather than the shared tooltip's list, because a streamgraph's
 * \`[lo, hi]\` are stacking offsets and the values the reader gave live on
 * w.streamgraphData. */
.apexcharts-tooltip-stream {
  padding: 5px 8px
}

.apexcharts-tooltip-stream .apexcharts-tooltip-title {
  background: transparent;
  border: 0;
  padding: 0 0 4px;
  margin: 0;
  font-weight: 700
}

.apexcharts-tooltip-stream-band {
  display: flex;
  align-items: center;
  gap: 5px;
  line-height: 1.6;
  opacity: .72
}

.apexcharts-tooltip-stream-band.apexcharts-active {
  opacity: 1;
  font-weight: 700
}

.apexcharts-tooltip-stream-band .series-name {
  flex: 1 1 auto;
  margin-right: 8px
}

.apexcharts-tooltip-stream-band .value {
  font-weight: 700;
  margin-left: auto
}

.apexcharts-tooltip-stream-total {
  display: flex;
  align-items: center;
  margin-top: 4px;
  padding-top: 4px;
  border-top: 1px solid var(--apx-tt-border, rgba(15, 23, 42, .12))
}

.apexcharts-tooltip-stream-total .series-name {
  flex: 1 1 auto;
  font-weight: 600
}

.apexcharts-tooltip-stream-total .value {
  font-weight: 700;
  margin-left: auto
}

/* The band labels themselves. Pointer events off so a name never blocks a
 * hover on the band it sits on. */
.apexcharts-streamgraph-label {
  pointer-events: none
}

/* X/Y axis tooltips — small popovers that label the crosshair on the
 * axes. Restyled to match the modern data-tooltip palette: solid white
 * body with a subtle border + soft drop-shadow, smaller font, rounded
 * corners. The arrows still use the CSS border-triangle technique
 * (cheap, crisp at small sizes); their colours flow from CSS variables
 * so light/dark themes only need one override per axis. */
.apexcharts-xaxistooltip,
.apexcharts-yaxistooltip {
  --apx-axt-bg: #ffffff;
  --apx-axt-border: rgba(15, 23, 42, 0.08);
  --apx-axt-color: #0f172a;
  --apx-axt-shadow: 0 4px 12px -4px rgba(15, 23, 42, 0.18), 0 1px 3px -1px rgba(15, 23, 42, 0.12);
  opacity: 0;
  pointer-events: none;
  color: var(--apx-axt-color);
  font-size: 12px;
  font-weight: 500;
  text-align: center;
  border-radius: 6px;
  position: absolute;
  z-index: 10;
  background: var(--apx-axt-bg);
  border: 1px solid var(--apx-axt-border);
  box-shadow: var(--apx-axt-shadow)
}

.apexcharts-xaxistooltip.apexcharts-theme-dark,
.apexcharts-yaxistooltip.apexcharts-theme-dark {
  --apx-axt-bg: #1c1c1f;
  --apx-axt-border: rgba(255, 255, 255, 0.1);
  --apx-axt-color: #f3f4f6;
  --apx-axt-shadow: 0 4px 12px -4px rgba(0, 0, 0, 0.55), 0 1px 3px -1px rgba(0, 0, 0, 0.45)
}

.apexcharts-xaxistooltip {
  padding: 4px 8px;
  transition: .15s ease all
}

.apexcharts-xaxistooltip:after,
.apexcharts-xaxistooltip:before {
  left: 50%;
  border: solid transparent;
  content: " ";
  height: 0;
  width: 0;
  position: absolute;
  pointer-events: none
}

/* :before paints the 1px border outline of the triangle (slightly larger
 * than :after); :after sits inside and paints the fill — leaves a 1px
 * ring of :before visible at the edges. */
.apexcharts-xaxistooltip:after {
  border-color: transparent;
  border-width: 5px;
  margin-left: -5px
}

.apexcharts-xaxistooltip:before {
  border-color: transparent;
  border-width: 6px;
  margin-left: -6px
}

.apexcharts-xaxistooltip-bottom:after,
.apexcharts-xaxistooltip-bottom:before {
  bottom: 100%
}

.apexcharts-xaxistooltip-top:after,
.apexcharts-xaxistooltip-top:before {
  top: 100%
}

.apexcharts-xaxistooltip-bottom:after {
  border-bottom-color: var(--apx-axt-bg)
}

.apexcharts-xaxistooltip-bottom:before {
  border-bottom-color: var(--apx-axt-border)
}

.apexcharts-xaxistooltip-top:after {
  border-top-color: var(--apx-axt-bg)
}

.apexcharts-xaxistooltip-top:before {
  border-top-color: var(--apx-axt-border)
}

.apexcharts-xaxistooltip.apexcharts-active {
  opacity: 1;
  transition: .15s ease all
}

.apexcharts-yaxistooltip {
  padding: 3px 8px
}

.apexcharts-yaxistooltip:after,
.apexcharts-yaxistooltip:before {
  top: 50%;
  border: solid transparent;
  content: " ";
  height: 0;
  width: 0;
  position: absolute;
  pointer-events: none
}

.apexcharts-yaxistooltip:after {
  border-color: transparent;
  border-width: 5px;
  margin-top: -5px
}

.apexcharts-yaxistooltip:before {
  border-color: transparent;
  border-width: 6px;
  margin-top: -6px
}

.apexcharts-yaxistooltip-left:after,
.apexcharts-yaxistooltip-left:before {
  left: 100%
}

.apexcharts-yaxistooltip-right:after,
.apexcharts-yaxistooltip-right:before {
  right: 100%
}

.apexcharts-yaxistooltip-left:after {
  border-left-color: var(--apx-axt-bg)
}

.apexcharts-yaxistooltip-left:before {
  border-left-color: var(--apx-axt-border)
}

.apexcharts-yaxistooltip-right:after {
  border-right-color: var(--apx-axt-bg)
}

.apexcharts-yaxistooltip-right:before {
  border-right-color: var(--apx-axt-border)
}

.apexcharts-yaxistooltip.apexcharts-active {
  opacity: 1
}

.apexcharts-yaxistooltip-hidden {
  display: none
}

.apexcharts-xcrosshairs,
.apexcharts-ycrosshairs {
  pointer-events: none;
  opacity: 0;
  transition: .15s ease all
}

.apexcharts-xcrosshairs.apexcharts-active,
.apexcharts-ycrosshairs.apexcharts-active {
  opacity: 1;
  transition: .15s ease all
}

.apexcharts-ycrosshairs-hidden {
  opacity: 0
}

.apexcharts-selection-rect {
  cursor: move
}

.svg_select_shape {
  stroke-width: 1;
  stroke-dasharray: 10 10;
  stroke: black;
  stroke-opacity: 0.1;
  pointer-events: none;
  fill: none;
}

.svg_select_handle {
  stroke-width: 3;
  stroke: black;
  fill: none;
}

.svg_select_handle_r {
  cursor: e-resize;
}

.svg_select_handle_l {
  cursor: w-resize;
}

.apexcharts-svg.apexcharts-zoomable.hovering-zoom {
  cursor: crosshair
}

.apexcharts-svg.apexcharts-zoomable.hovering-pan {
  cursor: move
}

.apexcharts-menu-icon,
.apexcharts-measure-icon,
.apexcharts-pan-icon,
.apexcharts-reset-icon,
.apexcharts-selection-icon,
.apexcharts-toolbar-custom-icon,
.apexcharts-zoom-icon,
.apexcharts-zoomin-icon,
.apexcharts-zoomout-icon {
  cursor: pointer;
  /* WCAG 2.5.8 Target Size (Minimum): 24×24 CSS px hit target. */
  width: 26px;
  height: 24px;
  line-height: 24px;
  color: #6e8192;
  text-align: center;
  /* Reset native <button> chrome — these are styled via SVG icons. */
  padding: 0;
  margin: 0;
  background: transparent;
  border: 0;
  border-radius: 5px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: background-color .12s ease, color .12s ease;
}

.apexcharts-menu-icon svg,
.apexcharts-measure-icon svg,
.apexcharts-pan-icon svg,
.apexcharts-reset-icon svg,
.apexcharts-selection-icon svg,
.apexcharts-zoom-icon svg,
.apexcharts-zoomin-icon svg,
.apexcharts-zoomout-icon svg {
  width: 18px;
  height: 18px;
  fill: none;
  stroke: currentColor;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round
}

.apexcharts-theme-dark .apexcharts-menu-icon,
.apexcharts-theme-dark .apexcharts-measure-icon,
.apexcharts-theme-dark .apexcharts-pan-icon,
.apexcharts-theme-dark .apexcharts-reset-icon,
.apexcharts-theme-dark .apexcharts-selection-icon,
.apexcharts-theme-dark .apexcharts-toolbar-custom-icon,
.apexcharts-theme-dark .apexcharts-zoom-icon,
.apexcharts-theme-dark .apexcharts-zoomin-icon,
.apexcharts-theme-dark .apexcharts-zoomout-icon {
  color: #d4d6dc
}

.apexcharts-canvas .apexcharts-measure-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-pan-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-reset-zoom-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-selection-icon.apexcharts-selected,
.apexcharts-canvas .apexcharts-zoom-icon.apexcharts-selected {
  background: rgba(0, 143, 251, 0.12);
  color: #008ffb
}

.apexcharts-theme-light .apexcharts-menu-icon:hover,
.apexcharts-theme-light .apexcharts-measure-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-pan-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-reset-icon:hover,
.apexcharts-theme-light .apexcharts-selection-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-zoom-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-light .apexcharts-zoomin-icon:hover,
.apexcharts-theme-light .apexcharts-zoomout-icon:hover {
  background: rgba(15, 23, 42, 0.06);
  color: #1f2937
}

.apexcharts-theme-dark .apexcharts-menu-icon:hover,
.apexcharts-theme-dark .apexcharts-measure-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-pan-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-reset-icon:hover,
.apexcharts-theme-dark .apexcharts-selection-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-zoom-icon:not(.apexcharts-selected):hover,
.apexcharts-theme-dark .apexcharts-zoomin-icon:hover,
.apexcharts-theme-dark .apexcharts-zoomout-icon:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #fff
}

.apexcharts-menu-icon,
.apexcharts-selection-icon {
  position: relative
}

.apexcharts-toolbar {
  position: absolute;
  z-index: 11;
  display: inline-flex;
  align-items: center;
  gap: 1px;
  padding: 3px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
}

.apexcharts-theme-dark .apexcharts-toolbar {
  background: rgba(28, 28, 31, 0.82);
}

.apexcharts-menu {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  position: absolute;
  top: calc(100% + 4px);
  border: 1px solid rgba(15, 23, 42, 0.08);
  border-radius: 8px;
  padding: 4px;
  right: 0;
  opacity: 0;
  min-width: 120px;
  transition: opacity .15s ease, transform .15s ease;
  transform: translateY(-2px);
  pointer-events: none;
  box-shadow: 0 4px 16px -4px rgba(15, 23, 42, 0.12), 0 2px 4px -1px rgba(15, 23, 42, 0.06)
}

.apexcharts-menu.apexcharts-menu-open {
  opacity: 1;
  transform: translateY(0);
  pointer-events: all
}

.apexcharts-menu-item {
  padding: 6px 9px;
  font-size: 12px;
  border-radius: 5px;
  cursor: pointer
}

.apexcharts-theme-light .apexcharts-menu-item:hover {
  background: rgba(15, 23, 42, 0.06)
}

.apexcharts-theme-dark .apexcharts-menu {
  background: rgba(28, 28, 31, 0.92);
  border-color: rgba(255, 255, 255, 0.08);
  color: #f3f4f6;
  box-shadow: 0 4px 16px -4px rgba(0, 0, 0, 0.5), 0 2px 4px -1px rgba(0, 0, 0, 0.4)
}

.apexcharts-theme-dark .apexcharts-menu-item:hover {
  background: rgba(255, 255, 255, 0.08)
}

@media screen and (min-width:768px) {
  .apexcharts-canvas:hover .apexcharts-toolbar {
    opacity: 1
  }
}

/* Toolbar keyboard accessibility: show toolbar when any button inside it is focused */
.apexcharts-toolbar:focus-within {
  opacity: 1
}

/* Focus indicator for toolbar icon buttons */
.apexcharts-menu-icon:focus-visible,
.apexcharts-measure-icon:focus-visible,
.apexcharts-pan-icon:focus-visible,
.apexcharts-reset-icon:focus-visible,
.apexcharts-selection-icon:focus-visible,
.apexcharts-toolbar-custom-icon:focus-visible,
.apexcharts-zoom-icon:focus-visible,
.apexcharts-zoomin-icon:focus-visible,
.apexcharts-zoomout-icon:focus-visible {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: 1px;
  border-radius: 5px
}

/* Focus indicator for hamburger menu items */
.apexcharts-menu-item:focus-visible {
  outline: 2px solid var(--apexcharts-focus-color, #008FFB);
  outline-offset: -2px;
  background: #eee
}

.apexcharts-canvas .apexcharts-element-hidden,
.apexcharts-datalabel.apexcharts-element-hidden,
.apexcharts-hide .apexcharts-series-points {
  opacity: 0;
}

.apexcharts-hidden-element-shown {
  opacity: 1;
  transition: 0.25s ease all;
}

.apexcharts-datalabel,
.apexcharts-datalabel-label,
.apexcharts-datalabel-value,
.apexcharts-datalabels,
.apexcharts-pie-label,
.apexcharts-pie-name-label,
.apexcharts-pie-name-label-group,
.apexcharts-pie-label-connector,
.apexcharts-unit-outer-label,
.apexcharts-unit-outer-label-group,
.apexcharts-unit-label-connector {
  cursor: default;
  pointer-events: none
}

.apexcharts-pie-label-connector,
.apexcharts-unit-label-connector {
  fill: none
}

.apexcharts-pie-label-delay,
.apexcharts-unit-label-delay {
  opacity: 0;
  animation-name: opaque;
  animation-duration: .3s;
  animation-fill-mode: forwards;
  animation-timing-function: ease
}

/* Slower than the pie's, on purpose: these come in while the dots are still
   easing into place, so a longer fade reads as arriving WITH the crowd. */
.apexcharts-unit-label-delay {
  animation-duration: .5s
}

.apexcharts-radialbar-label {
  cursor: pointer;
}

.apexcharts-annotation-rect,
.apexcharts-area-series .apexcharts-area,
.apexcharts-gridline,
.apexcharts-line,
.apexcharts-point-annotation-label,
.apexcharts-radar-series path:not(.apexcharts-marker),
.apexcharts-radar-series polygon,
.apexcharts-toolbar svg,
.apexcharts-tooltip .apexcharts-marker,
.apexcharts-xaxis-annotation-label,
.apexcharts-yaxis-annotation-label,
.apexcharts-zoom-rect,
.no-pointer-events {
  pointer-events: none
}

.apexcharts-tooltip-active .apexcharts-marker {
  transition: .15s ease all
}

.apexcharts-radar-series .apexcharts-yaxis {
  pointer-events: none;
}

.resize-triggers {
  animation: 1ms resizeanim;
  visibility: hidden;
  opacity: 0;
  height: 100%;
  width: 100%;
  overflow: hidden
}

.contract-trigger:before,
.resize-triggers,
.resize-triggers>div {
  content: " ";
  display: block;
  position: absolute;
  top: 0;
  left: 0
}

.resize-triggers>div {
  height: 100%;
  width: 100%;
  background: #eee;
  overflow: auto
}

.contract-trigger:before {
  overflow: hidden;
  width: 200%;
  height: 200%
}

.apexcharts-bar-goals-markers {
  pointer-events: none
}

.apexcharts-bar-shadows {
  pointer-events: none
}

.apexcharts-rangebar-goals-markers {
  pointer-events: none
}

.apexcharts-drilldown-target {
  cursor: pointer
}

.apexcharts-breadcrumb {
  position: absolute;
  z-index: 11;
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-size: 12px;
  font-family: inherit;
  padding: 2px 4px
}

.apexcharts-breadcrumb-item {
  background: transparent;
  border: none;
  padding: 2px 6px;
  border-radius: 3px;
  font: inherit;
  color: inherit;
  cursor: pointer;
  line-height: 1.2
}

.apexcharts-breadcrumb-item:hover:not(.apexcharts-breadcrumb-current) {
  background: rgba(0, 0, 0, 0.08)
}

.apexcharts-breadcrumb-arrow {
  margin-right: 4px;
  font-weight: 600;
  user-select: none
}

.apexcharts-breadcrumb-current {
  cursor: default;
  font-weight: 600;
  opacity: 0.85
}

.apexcharts-breadcrumb-separator {
  opacity: 0.5;
  user-select: none
}

.apexcharts-theme-dark .apexcharts-breadcrumb-item:hover:not(.apexcharts-breadcrumb-current) {
  background: rgba(255, 255, 255, 0.12)
}

.apexcharts-drilldown-loading {
  position: absolute;
  inset: 0;
  z-index: 12;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  font-size: 13px;
  font-family: inherit;
  color: inherit;
  background: rgba(255, 255, 255, 0.62);
  /* The chart underneath stays interactive-looking but must not take clicks
     while a level is resolving, or a second drill can start mid-fetch. */
  cursor: progress
}

.apexcharts-drilldown-loading-spinner {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  border: 2.5px solid rgba(0, 0, 0, 0.16);
  border-top-color: rgba(0, 0, 0, 0.55);
  animation: apexcharts-drilldown-spin 0.7s linear infinite
}

.apexcharts-drilldown-loading-text {
  opacity: 0.8
}

.apexcharts-theme-dark .apexcharts-drilldown-loading {
  background: rgba(30, 30, 30, 0.62)
}

.apexcharts-theme-dark .apexcharts-drilldown-loading-spinner {
  border-color: rgba(255, 255, 255, 0.22);
  border-top-color: rgba(255, 255, 255, 0.7)
}

@keyframes apexcharts-drilldown-spin {
  to {
    transform: rotate(360deg)
  }
}

@media (prefers-reduced-motion: reduce) {
  .apexcharts-drilldown-loading-spinner {
    animation: apexcharts-drilldown-pulse 1.4s ease-in-out infinite
  }

  @keyframes apexcharts-drilldown-pulse {
    0%, 100% {
      opacity: 0.35
    }

    50% {
      opacity: 1
    }
  }
}

.apexcharts-disable-transitions * {
  transition: none !important;
}
/* ── Trellis (#22): small multiples ─────────────────────────────────────── */
.apexcharts-trellis {
  position: relative;
}
.apexcharts-trellis-grid {
  display: grid;
}
.apexcharts-trellis-cell {
  min-width: 0;
  position: relative;
}
.apexcharts-trellis-header {
  font-size: 12px;
  font-weight: 600;
  line-height: 22px;
  height: 22px;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-title {
  font-size: 14px;
  font-weight: 700;
  padding: 2px 0 6px;
  color: var(--apx-fore, #373d3f);
}
/* Edge-label policy: a muted cell hides its axis-label INK, never the label
   SPACE — every panel keeps the identical plot rectangle, and flipping the
   policy on a resize is a class toggle, not a re-render. */
.apexcharts-trellis-mute-y .apexcharts-yaxis {
  opacity: 0;
}
.apexcharts-trellis-mute-x .apexcharts-xaxis {
  opacity: 0;
}
/* The shared toolbar floats at the top-right, so a grid that has one starts
   below it: from four columns on, the last cell's header (or a 2-D column
   strip label) would otherwise run under the buttons. One band for the whole
   grid, not per panel. */
.apexcharts-trellis-has-toolbar {
  padding-top: 24px;
}
/* 2-D faceting (P4): column labels once across the top, row labels once
   down the left. The row strip column is auto-sized; panel columns stay
   equal fractions, so panel alignment is independent of the strip width. */
.apexcharts-trellis-strip {
  font-size: 12px;
  font-weight: 600;
  color: var(--apx-fore, #373d3f);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.apexcharts-trellis-strip-column {
  text-align: center;
  line-height: 22px;
  height: 22px;
  align-self: end;
}
.apexcharts-trellis-strip-row {
  align-self: center;
  max-width: 140px;
  padding-right: 6px;
}
/* Empty (row, column) combinations. 'placeholder' keeps a REAL panel with a
   quiet label; 'skip' shows the tinted skeleton; 'hide' shows nothing while
   keeping the grid slot. */
.apexcharts-trellis-cell-empty {
  position: relative;
}
.apexcharts-trellis-empty-label {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  color: var(--apx-fore, #373d3f);
  opacity: 0.45;
  pointer-events: none;
}
.apexcharts-trellis-cell-hidden > * {
  visibility: hidden;
}
/* P5: one shared gradient strip is a heatmap grid's legend. The slot is
   content-sized inline (the strip svg's own box); centering is its own. */
.apexcharts-trellis-gradient-legend {
  margin: 10px auto 0;
}
/* Virtualization (P2): an unmounted panel's mount div reserves the exact
   panel height (inline min-height) so page height and scroll position never
   shift; the skeleton itself is a quiet tinted block. Deliberately not
   animated: a shimmering grid of 200 placeholders is noise. */
.apexcharts-trellis-panel.apexcharts-trellis-skeleton {
  background: var(--apx-fore, #373d3f);
  opacity: 0.05;
  border-radius: 4px;
}
/* tooltip: 'panel' — the group still syncs every panel's crosshair, but only
   the hovered cell shows its tooltip cards. */
.apexcharts-trellis[data-tooltip-mode='panel'] .apexcharts-trellis-cell:not(:hover) .apexcharts-tooltip,
.apexcharts-trellis[data-tooltip-mode='panel'] .apexcharts-trellis-cell:not(:hover) .apexcharts-xaxistooltip,
.apexcharts-trellis[data-tooltip-mode='panel'] .apexcharts-trellis-cell:not(:hover) .apexcharts-yaxistooltip {
  opacity: 0 !important;
}
/* tooltip: 'grid' (P3) — ALL per-panel tooltip ink is hidden (the group
   still computes it; the trellis card reads it) and one trellis-owned card
   follows the cursor with one row per panel. */
.apexcharts-trellis[data-tooltip-mode='grid'] .apexcharts-trellis-cell .apexcharts-tooltip,
.apexcharts-trellis[data-tooltip-mode='grid'] .apexcharts-trellis-cell .apexcharts-xaxistooltip,
.apexcharts-trellis[data-tooltip-mode='grid'] .apexcharts-trellis-cell .apexcharts-yaxistooltip {
  opacity: 0 !important;
}
.apexcharts-trellis-tooltip {
  position: absolute;
  top: 0;
  left: 0;
  z-index: 14;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.1s ease;
  background: var(--apx-bg, #fff);
  color: var(--apx-fore, #373d3f);
  border: 1px solid rgba(120, 120, 120, 0.25);
  border-radius: 5px;
  box-shadow: 2px 2px 6px -4px rgba(0, 0, 0, 0.4);
  font-size: 12px;
  min-width: 140px;
  max-width: 320px;
}
.apexcharts-trellis-tooltip-active {
  opacity: 1;
}
.apexcharts-trellis-tooltip .apexcharts-tooltip-title {
  padding: 5px 10px;
  font-weight: 600;
  background: rgba(120, 120, 120, 0.08);
  border-bottom: 1px solid rgba(120, 120, 120, 0.18);
  margin-bottom: 2px;
}
.apexcharts-trellis-tooltip-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  padding: 2px 10px;
  line-height: 1.6;
}
.apexcharts-trellis-tooltip-row-active {
  background: rgba(120, 120, 120, 0.1);
  font-weight: 600;
}
.apexcharts-trellis-tooltip-key {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.apexcharts-trellis-tooltip-vals {
  display: flex;
  gap: 10px;
  white-space: nowrap;
}
.apexcharts-trellis-tooltip-val {
  display: inline-flex;
  align-items: center;
  gap: 5px;
}
.apexcharts-trellis-tooltip-marker {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
  flex: none;
}
/* Panel promotion (P3): the promoted cell spans the grid; the rest park.
   The promoted panel is the only visible one, so both its axes unmute. */
.apexcharts-trellis-cell-promoted {
  grid-column: 1 / -1;
}
.apexcharts-trellis-cell-parked {
  display: none;
}
.apexcharts-trellis-cell-promoted.apexcharts-trellis-mute-y .apexcharts-yaxis,
.apexcharts-trellis-cell-promoted.apexcharts-trellis-mute-x .apexcharts-xaxis {
  opacity: 1;
}
.apexcharts-trellis-header-clickable {
  cursor: pointer;
}
.apexcharts-trellis-header-clickable:hover {
  text-decoration: underline;
  text-underline-offset: 3px;
}
.apexcharts-trellis-breadcrumb {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  padding: 2px 0 6px;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-breadcrumb-back {
  border: none;
  background: none;
  padding: 0;
  font-size: 12px;
  cursor: pointer;
  color: var(--apx-accent, #008ffb);
}
.apexcharts-trellis-breadcrumb-back:hover {
  text-decoration: underline;
}
.apexcharts-trellis-breadcrumb-sep {
  opacity: 0.5;
}
.apexcharts-trellis-breadcrumb-current {
  font-weight: 600;
}
/* The toolbar download menu (P3). */
.apexcharts-trellis-menu {
  position: absolute;
  top: 26px;
  right: 0;
  display: none;
  flex-direction: column;
  min-width: 132px;
  background: var(--apx-bg, #fff);
  border: 1px solid rgba(120, 120, 120, 0.25);
  border-radius: 5px;
  box-shadow: 2px 2px 6px -4px rgba(0, 0, 0, 0.4);
  padding: 4px;
  z-index: 15;
}
.apexcharts-trellis-menu-open {
  display: flex;
}
.apexcharts-trellis-menu-item {
  border: none;
  background: none;
  text-align: left;
  font-size: 12px;
  padding: 5px 8px;
  border-radius: 3px;
  cursor: pointer;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-menu-item:hover {
  background: rgba(120, 120, 120, 0.12);
}
.apexcharts-trellis-toolbar {
  position: absolute;
  top: 0;
  right: 0;
  display: flex;
  gap: 2px;
  z-index: 12;
}
.apexcharts-trellis-tool {
  border: 0;
  background: transparent;
  padding: 2px;
  cursor: pointer;
  border-radius: 3px;
  color: #6e8192;
  line-height: 0;
}
.apexcharts-trellis-tool:hover {
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-tool.apexcharts-selected {
  color: var(--apx-accent, #008ffb);
}
.apexcharts-trellis-legend {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 4px 14px;
  padding: 8px 10px 2px;
}
.apexcharts-trellis-legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  line-height: 1;
}
.apexcharts-trellis-legend-item .apexcharts-legend-marker {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  display: inline-block;
}
.apexcharts-trellis-legend-item .apexcharts-legend-text {
  font-size: 12px;
  color: var(--apx-fore, #373d3f);
}
.apexcharts-trellis-legend-item.apexcharts-inactive-legend {
  opacity: 0.45;
}

/* Printing (#3352). The sheet is narrower than the screen and nothing reports
   its width to the page, so a chart laid out for the screen would be cropped at
   the edge of the paper. The chart lays itself out again for print (see
   chart.print in the options); this caps whatever is left over so it shrinks to
   fit rather than being cut. Shrink only: a chart narrower than the page keeps
   the size it was drawn at. */
@media print {
  /* Scoped to the class the chart adds while it is laid out for the sheet: this
     pair of rules is only safe once an identity viewBox is in place, since
     without one a capped width crops the drawing instead of scaling it. A chart
     with chart.print.enabled:false gets neither, and prints as it always did. */
  .apexcharts-canvas.apexcharts-printing,
  .apexcharts-canvas.apexcharts-printing svg {
    max-width: 100% !important;
  }

  .apexcharts-canvas.apexcharts-printing svg {
    height: auto !important;
  }

  /* A scaled-down SVG is shorter than the box drawn for it, and the wrapper
     carries the pre-scale height inline, so without this a chart shrunk to fit a
     narrow column prints above a white gap the size of what it gave up. The
     host element's own inline min-height is cleared by _beforePrint. */
  .apexcharts-canvas.apexcharts-printing {
    height: auto !important;
  }

  .apexcharts-toolbar {
    display: none !important;
  }
}
`;let i=((h=this.opts.chart)==null?void 0:h.nonce)||this.w.config.chart.nonce;i&&r.setAttribute(`nonce`,i),t?e.prepend(r):this.w.config.chart.injectStyleSheet!==!1&&n.head.appendChild(r)}}if(b){this.trellis.render().then(()=>{dr(this.w,this),typeof this.w.config.chart.events.mounted==`function`&&this.w.config.chart.events.mounted(this,this.w),this.events.fireEvent(`mounted`,[this,this.w]),e(this)}).catch(e=>{var n,r;let i=e instanceof Error?e:Error(String(e)),a=i;a.chartId=(r=(n=this.w)==null?void 0:n.globals)==null?void 0:r.chartID,a.el=this.el,t(i)});return}let x=this.create(this.w.config.series,{});if(!x)return e(this);this.mount(x).then(()=>{typeof this.w.config.chart.events.mounted==`function`&&this.w.config.chart.events.mounted(this,this.w),this.events.fireEvent(`mounted`,[this,this.w]),e(x)}).catch(e=>{var n,r;let i=e instanceof Error?e:Error(String(e)),a=i;a.chartId=(r=(n=this.w)==null?void 0:n.globals)==null?void 0:r.chartID,a.el=this.el,t(i)})}else t(/* @__PURE__ */ Error(`Element not found`))});return this._renderPromise=n,n.catch(()=>{this._renderPromise===n&&(this._renderPromise=null)}),n}create(e,t){var n,r,i,a,o,s;let c=this.w;this.core||new InitCtxVariables(this).initModules();let u=this.w.globals;if(u.noData=!1,u.animationEnded=!1,!_.elementExists(this.el)||(this.responsive.checkResponsiveConfig(t),we(c),c.config.xaxis.convertedCatToNumeric&&new Defaults(c.config).convertCatToNumericXaxis(c.config,this.ctx),this.core.setupElements(),c.config.chart.type===`treemap`&&(c.config.grid.show=!1,c.config.yaxis[0].show=!1),u.svgWidth===0))return u.animationEnded=!0,null;let d=e;e.forEach((e,t)=>{e.hidden&&(d=this.legend.legendHelpers.getSeriesAfterCollapsing({realIndex:t}))});let f=CoreUtils.checkComboSeries(d,c.config.chart.type);u.comboCharts=f.comboCharts,u.comboBarCount=f.comboBarCount;let p=d.every(e=>e.data&&e.data.length===0);(d.length===0||p&&u.collapsedSeries.length<1)&&this.series.handleNoData(),Environment.isBrowser()&&this.events.setupEventHandlers();let m=this.data.parseData(d);this._writeParsedSeriesData(m.seriesData),this._writeParsedRangeData(m.rangeData),this._writeParsedCandleData(m.candleData),this._writeParsedLabelData(m.labelData),this._writeParsedAxisFlags(m.axisFlags),(n=this.rendererController)==null||n.resolve(),(r=this.weave)==null||r.dispatch(`afterParse`),this.theme.init(),new Markers(this.w,this).setGlobalMarkerSize(),this.formatters.setLabelFormatters(),this.titleSubtitle.draw(),(!u.noData||u.collapsedSeries.length===c.seriesData.series.length||c.config.legend.showForSingleSeries)&&((i=this.legend)==null||i.init()),this.series.hasAllSeriesEqualX(),u.axisCharts&&(this.core.coreCalculations(),c.config.xaxis.type!==`category`&&this.formatters.setLabelFormatters(),this.ctx.toolbar&&(this.ctx.toolbar.minX=c.globals.minX,this.ctx.toolbar.maxX=c.globals.maxX)),this.formatters.heatmapLabelFormatters(),new CoreUtils(this.w).getLargestMarkerSize();let h=this.dimensions.plotCoords();this._writeLayoutCoords(h.layout);let g=this.core.xySettings();(a=this.weave)==null||a.dispatch(`afterScales`,{xyRatios:g}),this.grid.createGridMask();let v=this.core.plotChartType(d,g),y=new DataLabels(this.w,this);return y.bringForward(),c.config.dataLabels.background.enabled&&y.dataLabelsBackground(),this.core.shiftGraphPosition(),(s=(o=this.legend)==null?void 0:o.heatmapGradientLegend)==null||s.repositionToPlot(),c.globals.dataPoints>50&&c.dom.elWrap.classList.add(`apexcharts-disable-transitions`),{elGraph:v,xyRatios:g,dimensions:{plot:{left:c.layout.translateX,top:c.layout.translateY,width:c.layout.gridWidth,height:c.layout.gridHeight}}}}mount(e=null){let t=this,n=t.w;return new Promise((r,i)=>{var a,o,s,c,u,d,f,p,m,h,g,_;if(t.el===null)return i(/* @__PURE__ */ Error(`Not enough data to display or target element not found`));n.globals.allSeriesCollapsed&&t.series.handleNoData(),t.grid=new Grid(t.w,t);let v=t.grid.drawGrid(),y=InitCtxVariables._featureRegistry.get(`annotations`);if(t.annotations=y?new y(t.w,{theme:t.theme,timeScale:t.timeScale}):null,(a=t.annotations)==null||a.drawImageAnnos(),(o=t.annotations)==null||o.drawTextAnnos(),n.config.grid.position===`back`&&(v&&n.dom.elGraphical.add(v.el),(s=v==null?void 0:v.elGridBorders)!=null&&s.node&&n.dom.elGraphical.add(v.elGridBorders)),Array.isArray(e.elGraph))for(let t=0;t<e.elGraph.length;t++)n.dom.elGraphical.add(e.elGraph[t]);else n.dom.elGraphical.add(e.elGraph);n.config.grid.position===`front`&&(v&&n.dom.elGraphical.add(v.el),(c=v==null?void 0:v.elGridBorders)!=null&&c.node&&n.dom.elGraphical.add(v.elGridBorders)),(u=t.waterfall)==null||u.drawConnectors(),(d=t.streamgraph)==null||d.draw(),n.config.xaxis.crosshairs.position===`front`&&t.crosshairs.drawXCrosshairs(),n.config.yaxis[0].crosshairs.position===`front`&&t.crosshairs.drawYCrosshairs(),n.config.chart.type!==`treemap`&&t.axes.drawAxis(n.config.chart.type,v);let b=new XAxis(this.w,this.ctx,v),x=new YAxis(this.w,{theme:this.theme,timeScale:this.timeScale},v);if(v!==null&&(b.xAxisLabelCorrections(),x.setYAxisTextAlignments(),n.config.yaxis.map((e,t)=>{n.globals.ignoreYAxisIndexes.indexOf(t)===-1&&x.yAxisTitleRotate(t,e.opposite)})),(f=t.annotations)==null||f.drawAxesAnnotations(),!n.globals.noData){if(Environment.isBrowser()&&n.config.tooltip.enabled&&!n.globals.noData&&((p=t.w.globals.tooltip)==null||p.drawTooltip(e.xyRatios)),n.config.chart.accessibility.enabled&&n.config.chart.accessibility.keyboard.enabled&&n.config.chart.accessibility.keyboard.navigation.enabled&&((m=t.keyboardNavigation)==null||m.init()),Environment.isBrowser()&&n.globals.axisCharts&&(n.axisFlags.isXNumeric||n.config.xaxis.convertedCatToNumeric||n.axisFlags.isRangeBar))(n.config.chart.zoom.enabled||n.config.chart.selection&&n.config.chart.selection.enabled||n.config.chart.pan&&n.config.chart.pan.enabled)&&((h=t.zoomPanSelection)==null||h.init({xyRatios:e.xyRatios}));else{let e=n.config.chart.toolbar.tools;[`zoom`,`zoomin`,`zoomout`,`selection`,`pan`,`reset`].forEach(t=>{e[t]=!1})}n.config.chart.toolbar.show&&!n.globals.allSeriesCollapsed&&((g=t.toolbar)==null||g.createToolbar())}(_=t.weave)==null||_.dispatch(`draw`,{pass:`full`,xyRatios:e==null?void 0:e.xyRatios}),n.globals.memory.methodsToExec.length>0&&n.globals.memory.methodsToExec.forEach(e=>{e.method(e.params,!1,e.context)}),!n.globals.axisCharts&&!n.globals.noData&&t.core.resizeNonAxisCharts(),dr(n,t),r(t)})}destroy(){var e,t;this.trellis&&this.trellis.teardown(),this._renderPromise=null,Environment.isBrowser()&&(window.removeEventListener(`resize`,this.windowResizeHandler),Wn(this.el.parentNode,this.parentResizeHandler),clearTimeout((e=this.w.globals.resizeTimer)==null?void 0:e),clearTimeout((t=this._parentResizeWaiter)==null?void 0:t),this._parentResizeWaiter=null,window.removeEventListener(`beforeprint`,this.beforePrintHandler),window.removeEventListener(`afterprint`,this.afterPrintHandler));let n=this.w.config.chart.id;n&&Array.isArray(Apex._chartInstances)&&Apex._chartInstances.forEach((e,t)=>{e.id===_.escapeString(n)&&Apex._chartInstances.splice(t,1)}),this._keyboardNavigation&&this._keyboardNavigation.destroy(),lr(this),nr(this),new Destroy(this.ctx).clear({isUpdating:!1})}updateOptions(e,t=!1,n=!0,r=!0,i=!0){let a=this.w;if(e&&`series`in e&&!Array.isArray(e.series)&&(console.warn("ApexCharts: updateOptions() ignored `series` because it is not an array."),e=s({},e),delete e.series),this.trellis&&this.trellis._mounted)return this.opts=_.extend(this.opts||{},e||{}),this.w.config=_.extend(a.config,e||{}),this.trellis.teardown(),this.render();if(a.interact.selection=void 0,this.lastUpdateOptions){if(_.shallowEqual(this.lastUpdateOptions,e))return Promise.resolve(this);if(e.series&&this.lastUpdateOptions.series&&!_ApexCharts._optionsTooBigToCompare(e)&&_.stringifyForCompare(this.lastUpdateOptions.series)===_.stringifyForCompare(e.series)){let t=s({},e),n=s({},this.lastUpdateOptions);if(delete t.series,delete n.series,_.shallowEqual(t,n))return Promise.resolve(this)}}return e.series&&(this.data.resetParsingFlags(),this.series.resetSeries(!1,!0,!1),e.series.length&&e.series[0].data&&(e.series=e.series.map((e,t)=>this.updateHelpers._extendSeries(e,t))),this.updateHelpers.revertDefaultAxisMinMax()),e.xaxis&&(e=this.updateHelpers.forceXAxisUpdate(e)),e.yaxis&&(e=this.updateHelpers.forceYAxisUpdate(e)),a.globals.collapsedSeriesIndices.length>0&&this.series.clearPreviousPaths(),e.theme&&(e=this.theme.updateThemeOptions(e)),this.updateHelpers._updateOptions(e,t,n,r,i)}updateSeries(e=[],t=!0,n=!0){return Array.isArray(e)?this.trellis&&this.trellis._mounted?this.trellis.updateSeries(e,t):(this.data.resetParsingFlags(),this.series.prepareDataUpdate(),this.updateHelpers.revertDefaultAxisMinMax(),this.updateHelpers._updateSeries(e,t,n)):(console.warn(`ApexCharts: updateSeries() ignored the call because the series is not an array.`),Promise.resolve(this))}appendSeries(e,t=!0,n=!0){this.data.resetParsingFlags();let r=this.w.config.series.slice();return r.push(e),this.series.prepareDataUpdate(),this.updateHelpers.revertDefaultAxisMinMax(),this.updateHelpers._updateSeries(r,t,n)}appendData(e,t=!0){let n=this;n.data.resetParsingFlags(),n.w.globals.dataChanged=!0,n.w.config.chart.animations.enabled&&n.series.getPreviousPaths();let r=n.w.globals.histogramRawSeries||n.w.globals.waterfallRawSeries||n.w.globals.dumbbellRawSeries||n.w.globals.streamgraphRawSeries;if(r){for(let t=0;t<r.length;t++){let n=e[t];if(n&&Array.isArray(n.data)&&Array.isArray(r[t].data))for(let e=0;e<n.data.length;e++)r[t].data.push(n.data[e])}return this.update()}let i=n.w.config.series.slice();for(let t=0;t<i.length;t++)if(e[t]!==null&&e[t]!==void 0){let n=e[t],r=i[t];for(let e=0;e<n.data.length;e++)r.data.push(n.data[e])}return Fe(i,n.w),n.w.config.series=i,t&&(n.w.globals.initialSeries=n.w.config.series),this.update()}static _optionsTooBigToCompare(e){let t=e&&e.series;if(!Array.isArray(t))return!1;let n=0;for(let e=0;e<t.length;e++){let r=t[e]&&t[e].data;if(n+=Array.isArray(r)?r.length:1,n>1e3)return!0}return!1}update(e){return new Promise((t,n)=>{if(e&&this.lastUpdateOptions&&!_ApexCharts._optionsTooBigToCompare(e)&&_.stringifyForCompare(this.lastUpdateOptions)===_.stringifyForCompare(e))return t(this);this.lastUpdateOptions=e&&!_ApexCharts._optionsTooBigToCompare(e)?_.clone(e):null,new Destroy(this.ctx).clear({isUpdating:!0});let r=this.create(this.w.config.series,e==null?{}:e);if(!r)return t(this);this.mount(r).then(()=>{var e;(e=this.morphTypeChange)==null||e.applyChromeFade(),ot(this.w),_t(this.w),typeof this.w.config.chart.events.updated==`function`&&this.w.config.chart.events.updated(this,this.w),this.events.fireEvent(`updated`,[this,this.w]),this.w.globals.isDirty=!0,t(this)}).catch(e=>{n(e)})})}_fastAxisChromeRefresh(e){let t=this.w,n=t.globals;this._fastAxisBailReason=``;try{if(n.isBarHorizontal)return this._fastAxisBailReason=`barHorizontal`,!1;if(t.config.chart.sparkline.enabled)return!0;let e=t.config.annotations;if(e&&(e.yaxis&&e.yaxis.length||e.xaxis&&e.xaxis.length||e.points&&e.points.length||e.texts&&e.texts.length||e.images&&e.images.length))return this._fastAxisBailReason=`annotations`,!1;if(t.config.chart.ink&&t.config.chart.ink.enabled)return this._fastAxisBailReason=`ink`,!1;let r=this.dimensions;if(!r||!r.dimYAxis)return this._fastAxisBailReason=`noDimensions`,!1;let i=t.layout.yLabelsCoords,a=t.layout.yTitleCoords,o=r.dimYAxis.getyAxisLabelsCoords(),s=r.dimYAxis.getyAxisTitleCoords();t.layout.yLabelsCoords=[],t.layout.yTitleCoords=[],t.config.yaxis.map((e,n)=>{t.layout.yLabelsCoords.push({width:o[n].width,index:n}),t.layout.yTitleCoords.push({width:s[n].width,index:n})});let c=r.dimYAxis.getTotalYAxisWidth();if(c>r.yAxisWidth+2)return t.layout.yLabelsCoords=i,t.layout.yTitleCoords=a,this._fastAxisBailReason=`labelWidth ${c} > ${r.yAxisWidth}`,!1;let u=t.dom.elGraphical.node,d=u.querySelector(`.apexcharts-grid`),f=u.querySelector(`.apexcharts-grid-borders`);if(!d)return this._fastAxisBailReason=`missingGridNode`,!1;let p=d.parentNode,m=f?f.nextSibling:d.nextSibling;d.remove(),f&&f.remove(),u.querySelectorAll(`.apexcharts-xaxis-tick`).forEach(e=>e.remove()),this.grid=new Grid(t,this);let h=this.grid.drawGrid();h&&h.el&&(p.insertBefore(h.el.node,m),h.elGridBorders&&h.elGridBorders.node&&p.insertBefore(h.elGridBorders.node,m));let g=new XAxis(this.w,this.ctx,h),_=u.querySelector(`.apexcharts-xaxis`);if(_){let e=_.parentNode,t=_.nextSibling;_.remove();let n=g.drawXaxis();e.insertBefore(n.node,t)}let v=new YAxis(this.w,{theme:this.theme,timeScale:this.timeScale},h);for(let e=0;e<t.config.yaxis.length;e++){if(n.ignoreYAxisIndexes.indexOf(e)!==-1)continue;let r=t.dom.baseEl.querySelector(`.apexcharts-yaxis[rel='${e}']`);if(!r)return this._fastAxisBailReason=`missingYAxisNode`,!1;let i=r.parentNode;if(!i)return this._fastAxisBailReason=`missingYAxisParent`,!1;let a=r.nextSibling;r.remove();let o=v.drawYaxis(e);i.insertBefore(o.node,a)}return h!==null&&(g.xAxisLabelCorrections(),v.setYAxisTextAlignments(),t.config.yaxis.map((e,t)=>{n.ignoreYAxisIndexes.indexOf(t)===-1&&v.yAxisTitleRotate(t,e.opposite)})),!0}catch(e){return this._fastAxisBailReason=`error: `+(e&&e.message),!1}}fastUpdate(e,t){return new Promise((n,r)=>{var i,a,o,s,c;try{let u=this.w,d=u.globals;d.shouldAnimate=e,d.dataChanged=!0,d.animationEnded=!1,PerformanceCache.invalidateSelectors(u);let f=u.globals;f.maxY=-Number.MAX_VALUE,f.minY=Number.MIN_VALUE,f.minYArr=[],f.maxYArr=[],f.maxX=-Number.MAX_VALUE,f.minX=Number.MAX_VALUE,f.initialMaxX=-Number.MAX_VALUE,f.initialMinX=Number.MAX_VALUE,f.yAxisScale=[],f.xAxisScale=null,f.xAxisTicksPositions=[],f.xRange=0,f.yRange=[],f.zRange=0,f.xTickAmount=0,f.multiAxisTickAmount=0,f.pointsArray=[],f.barCanvasCoords=null,f.dataLabelsRects=[],f.lastDrawnDataLabelsIndexes=[],f.textRectsCache=/* @__PURE__ */ new Map,f.domCache=/* @__PURE__ */ new Map,f.cachedSelectors={},f.disableZoomIn=!1,f.disableZoomOut=!1,d.axisCharts&&(this.core.coreCalculations(),u.config.xaxis.type!==`category`&&this.formatters.setLabelFormatters()),this.formatters.heatmapLabelFormatters();let p=this.core.xySettings();this._zoomPanSelection&&(this._zoomPanSelection.xyRatios=p);let m=JSON.stringify({y:(d.yAxisScale||[]).map(e=>e?e.result:null),xMin:d.minX,xMax:d.maxX}),h=d.axisCharts&&t!=null&&m!==t;if(h&&!this._fastAxisChromeRefresh(p))return this._updateStats.full++,this.update().then(()=>n(this)).catch(r);h?this._updateStats.fastWithAxes++:this._updateStats.fast++,(i=this.weave)==null||i.dispatch(`afterScales`,{pass:`fast`,xyRatios:p});let g=this.ctx.renderer,_=!!(g&&g.kind===`canvas`&&g.canRepaintInPlace&&g.canRepaintInPlace());_&&(g._repaintHostInPlace=!0);let v=u.dom.elGraphical.node;v.querySelectorAll((_?``:`.apexcharts-canvas-series-wrap, `)+`.apexcharts-plot-series, .apexcharts-series, .apexcharts-datalabels, .apexcharts-datalabels-background`).forEach(e=>{var t;return(t=e.parentNode)==null?void 0:t.removeChild(e)});let y=this.core.plotChartType(u.config.series,p),b=v.querySelector(`.apexcharts-grid`),x=v.querySelector(`.apexcharts-xaxis`),S=Array.isArray(y)?y:[y],C=b&&u.config.grid.position===`front`?b:x;C?S.forEach(e=>{let t=e&&e.node?e.node:e;t&&v.insertBefore(t,C)}):S.forEach(e=>{u.dom.elGraphical.add(e)});let w=new DataLabels(u,this);w.bringForward(),u.config.dataLabels.background.enabled&&w.dataLabelsBackground(),(a=this.waterfall)==null||a.drawConnectors(),(o=this.streamgraph)==null||o.draw(),d.streamScrolled||ot(u),_t(u),Environment.isBrowser()&&u.config.tooltip.enabled&&!d.noData&&((s=u.globals.tooltip)==null||s.drawTooltip(p)),(c=this.weave)==null||c.dispatch(`draw`,{pass:`fast`,xyRatios:p}),typeof u.config.chart.events.updated==`function`&&u.config.chart.events.updated(this,u),this.events.fireEvent(`updated`,[this,u]),dr(u,this),d.isDirty=!0,n(this)}catch(e){r(e)}})}getSyncedCharts(){let e=this.getGroupedCharts();return e.splice(0,0,this),e}getPanels(){return this.trellis?this.trellis.getPanels():[]}getPanel(e){return this.trellis?this.trellis.getPanel(e):null}getGroupedCharts(){return Apex._chartInstances.filter(e=>this!==e.chart&&!!this.w.config.chart.group&&this.w.config.chart.group===e.group).map(e=>e.chart)}static getChartByID(e){let t=_.escapeString(e);if(!Apex._chartInstances)return;let n=Apex._chartInstances.filter(e=>e.id===t)[0];return n&&n.chart}static trellis(e,t){if(!InitCtxVariables._featureRegistry.get(`trellis`))return console.warn(`ApexCharts.trellis requires the trellis feature, which is not in the default bundle. Bundler: import 'apexcharts/features/trellis'. Script tag: add <script src='.../dist/features/trellis.js'> after apexcharts.js.`),null;let n=new _ApexCharts(e,t);return n.render(),n}static initOnLoad(){var e;let t=document.querySelectorAll(`[data-apexcharts]`);for(let n=0;n<t.length;n++){let r=t[n];new _ApexCharts(r,JSON.parse((e=t[n].getAttribute(`data-options`))==null?``:e)).render()}}static exec(e,t,...n){let r=this.getChartByID(e);if(!r)return;r.w.globals.isExecCalled=!0;let i=null;return r.publicMethods.indexOf(t)!==-1&&(i=r[t](...n)),i}static merge(e,t){return _.extend(e,t)}static getThemePalettes(){return Me()}static use(e){qt(e)}static registerFeatures(e){InitCtxVariables.registerFeatures(e)}static setLicense(e){return Q.setLicense(e),fr(),_ApexCharts}static registerPlugin(e){return Bn(e),_ApexCharts}static unregisterPlugin(e){return Vn(e),_ApexCharts}static registerRenderer(e,t){RendererController.registerRenderer(e,t)}static registerSeriesType(e,t){let n=_ApexCharts._customSeriesFactory;return n?!t||typeof t.renderItem!=`function`?(console.warn(`[apexcharts] registerSeriesType("${e}") needs a def with a renderItem() function.`),_ApexCharts):Gt(e)&&!X(e)||b[e]?(console.warn(`[apexcharts] registerSeriesType("${e}") would override the built-in "${e}" chart type; pick another name.`),_ApexCharts):(qt({[e]:n(e,t)}),Wt(e),_ApexCharts):(console.warn(`[apexcharts] registerSeriesType("${e}") requires the Marks feature: import 'apexcharts/features/marks'.`),_ApexCharts)}static unregisterSeriesType(e){return X(e)&&Kt(e),_ApexCharts}static registerTheme(e,t){return Ct(e,t),_ApexCharts}static unregisterTheme(e){return Tt(e),_ApexCharts}static registerEasing(e,t){return me(e,t),_ApexCharts}static registerUnitLayout(e,t){return Tn(e,t),_ApexCharts}static unregisterUnitLayout(e){return En(e),_ApexCharts}static registerUnitMark(e,t){return An(e,t),_ApexCharts}static unregisterUnitMark(e){return jn(e),_ApexCharts}static registerRowSource(e,t){return Pn(e,t),_ApexCharts}static unregisterRowSource(e){return In(e),_ApexCharts}rowSeries(e){let t=Ln(this.w);return t&&t(this.w,e)||null}static crossfilter(e){if(!e||typeof e.id!=`string`)throw Error(`ApexCharts.crossfilter requires an { id } string.`);let t=_ApexCharts._crossfilterFactory;if(!t)return console.warn(`[apexcharts] ApexCharts.crossfilter(...) requires the link feature, which is not in the default bundle. Bundler: import 'apexcharts/features/link'. Script tag: add <script src='.../dist/features/link.js'> after apexcharts.js.`),null;let n=t(e);return fr(),n}static getCrossfilter(e){let t=_ApexCharts._crossfilterGet;return t?t(e):null}clearCrossfilter(){var e;(e=this.linkedViews)==null||e.clearGroup()}startMeasure(){var e;(e=this.measure)==null||e.startMeasure()}stopMeasure(){var e;(e=this.measure)==null||e.stopMeasure()}clearMeasures(){var e;(e=this.measure)==null||e.clearMeasures()}toggleSeries(e){return this.series.toggleSeries(e)}highlightSeriesOnLegendHover(e,t){return this.series.toggleSeriesOnHover(e,t)}showSeries(e){this.series.showSeries(e)}hideSeries(e){this.series.hideSeries(e)}highlightSeries(e){this.series.highlightSeries(e)}isSeriesHidden(e){return this.series.isSeriesHidden(e)}resetSeries(e=!0,t=!0){this.series.resetSeries(e,t)}addEventListener(e,t){this.events.addEventListener(e,t)}removeEventListener(e,t){this.events.removeEventListener(e,t)}addXaxisAnnotation(e,t=!0,n=void 0){var r;let i=this;n&&(i=n),(r=i.annotations)==null||r.addXaxisAnnotationExternal(e,t,i)}addYaxisAnnotation(e,t=!0,n=void 0){var r;let i=this;n&&(i=n),(r=i.annotations)==null||r.addYaxisAnnotationExternal(e,t,i)}addPointAnnotation(e,t=!0,n=void 0){var r;let i=this;n&&(i=n),(r=i.annotations)==null||r.addPointAnnotationExternal(e,t,i)}clearAnnotations(e=void 0){var t;let n=this;e&&(n=e),n.lastUpdateOptions=null,(t=n.annotations)==null||t.clearAnnotations(n)}removeAnnotation(e,t=void 0){var n;let r=this;t&&(r=t),r.lastUpdateOptions=null,(n=r.annotations)==null||n.removeAnnotation(r,e)}getChartArea(){return this.w.dom.baseEl.querySelector(`.apexcharts-inner`)}getSeriesTotalXRange(e,t){return this.coreUtils.getSeriesTotalsXRange(e,t)}getHighestValueInSeries(e=0){return new Range(this.w).getMinYMaxY(e).highestY}getLowestValueInSeries(e=0){return new Range(this.w).getMinYMaxY(e).lowestY}getSeriesTotal(){return this.w.globals.seriesTotals}getState(){let e=this.w,t=e.globals;return{series:e.seriesData.series,seriesNames:e.seriesData.seriesNames,colors:t.colors,labels:e.labelData.labels,seriesTotals:t.seriesTotals,seriesPercent:t.seriesPercent,seriesXvalues:t.seriesXvalues,seriesYvalues:t.seriesYvalues,minX:t.minX,maxX:t.maxX,minY:t.minY,maxY:t.maxY,minYArr:t.minYArr,maxYArr:t.maxYArr,minXDiff:t.minXDiff,dataPoints:t.dataPoints,xAxisScale:t.xAxisScale,yAxisScale:t.yAxisScale,xTickAmount:t.xTickAmount,isXNumeric:e.axisFlags.isXNumeric,seriesYAxisMap:t.seriesYAxisMap,seriesYAxisReverseMap:t.seriesYAxisReverseMap,svgWidth:t.svgWidth,svgHeight:t.svgHeight,gridWidth:e.layout.gridWidth,gridHeight:e.layout.gridHeight,selectedDataPoints:e.interact.selectedDataPoints,collapsedSeriesIndices:t.collapsedSeriesIndices,zoomed:e.interact.zoomed,seriesX:e.seriesData.seriesX,seriesZ:e.seriesData.seriesZ,seriesCandleO:e.candleData.seriesCandleO,seriesCandleH:e.candleData.seriesCandleH,seriesCandleM:e.candleData.seriesCandleM,seriesCandleL:e.candleData.seriesCandleL,seriesCandleC:e.candleData.seriesCandleC,seriesRangeStart:e.rangeData.seriesRangeStart,seriesRangeEnd:e.rangeData.seriesRangeEnd,seriesGoals:e.seriesData.seriesGoals}}toggleDataPointSelection(e,t){return this.updateHelpers.toggleDataPointSelection(e,t)}zoomX(e,t){var n;(n=this.ctx.toolbar)==null||n.zoomUpdateOptions(e,t)}setLocale(e){this.localization.setCurrentLocaleValues(e)}dataURI(e){if(!this.ctx.exports)throw Error(`apexcharts: Exports feature is not registered. Import apexcharts/features/exports.`);return this.trellis&&this.trellis._mounted?this.trellis.exports.dataURI(e):this.ctx.exports.dataURI(e)}getSvgString(e){if(!this.ctx.exports)throw Error(`apexcharts: Exports feature is not registered. Import apexcharts/features/exports.`);return this.trellis&&this.trellis._mounted?this.trellis.exports.svgString():this.ctx.exports.getSvgString(e)}exportToCSV(e={}){if(!this.ctx.exports)throw Error(`apexcharts: Exports feature is not registered. Import apexcharts/features/exports.`);return this.trellis&&this.trellis._mounted?this.trellis.exports.download(`csv`):this.ctx.exports.exportToCSV(e)}promotePanel(e){return this.trellis&&this.trellis._mounted?this.trellis.promote(e):Promise.resolve()}restorePanels(){return this.trellis&&this.trellis._mounted?this.trellis.restorePromotion():Promise.resolve()}paper(){return this.w.dom.Paper}getActiveRenderer(){return this.rendererController?this.rendererController.getActiveKind():`svg`}refreshTokens(){return this.lastUpdateOptions=null,this.update()}drillDown(e){if(!this.ctx.drilldown)throw Error(`apexcharts: Drilldown feature is not registered. Import apexcharts/features/drilldown.`);return this.ctx.drilldown.drillDown(e)}drillUp(){if(!this.ctx.drilldown)throw Error(`apexcharts: Drilldown feature is not registered. Import apexcharts/features/drilldown.`);return this.ctx.drilldown.drillUp()}drillToRoot(){if(!this.ctx.drilldown)throw Error(`apexcharts: Drilldown feature is not registered. Import apexcharts/features/drilldown.`);return this.ctx.drilldown.drillToRoot()}clearDrilldownCache(e){if(!this.ctx.drilldown)throw Error(`apexcharts: Drilldown feature is not registered. Import apexcharts/features/drilldown.`);return this.ctx.drilldown.clearCache(e)}static _writeDataProps(e,t){for(let n of Object.keys(t)){let r=Object.getOwnPropertyDescriptor(t,n);r&&`value`in r&&(e[n]=r.value)}}_writeParsedSeriesData(e){_ApexCharts._writeDataProps(this.w.seriesData,e)}_writeParsedRangeData(e){_ApexCharts._writeDataProps(this.w.rangeData,e)}_writeParsedCandleData(e){_ApexCharts._writeDataProps(this.w.candleData,e)}_writeParsedLabelData(e){_ApexCharts._writeDataProps(this.w.labelData,e)}_writeParsedAxisFlags(e){_ApexCharts._writeDataProps(this.w.axisFlags,e)}_writeLayoutCoords(e){_ApexCharts._writeDataProps(this.w.layout,e)}_parentResizeCallback(){if(this.w.config.chart.redrawOnParentResize){if(!this.w.globals.animationEnded){this._deferParentResize();return}this._windowResize()}}_deferParentResize(){var e;if(this._parentResizeWaiter)return;let t=Date.now(),n=((e=this.w.config.chart.animations)==null?void 0:e.speed)||800,r=Math.min(Math.max(1e3+n*2,1500),15e3),i=()=>{if(this._parentResizeWaiter=null,!(this.w.globals.isDestroyed||!_.elementExists(this.el))){if(this.w.globals.animationEnded||Date.now()-t>=r){this._windowResize();return}this._parentResizeWaiter=window.setTimeout(i,100)}};this._parentResizeWaiter=window.setTimeout(i,100)}_printEnabled(){let e=this.w.config.chart.print;return e!==!1&&(e==null?void 0:e.enabled)!==!1}_beforePrint(){var e,t,n,r,i,a;if(this._printRestore||!this._printEnabled())return;let o=this.w,s=(t=(e=o.config.chart.print)==null?void 0:e.width)==null?700:t;this._printRestore={width:o.config.chart.width},typeof s==`number`&&s>0&&o.globals.svgWidth>s&&this.updateHelpers._updateOptions({chart:{width:s}},!1,!1,!1,!1);let c=(r=(n=o.dom)==null?void 0:n.Paper)==null?void 0:r.node;if(c&&!c.getAttribute(`viewBox`)){c.setAttribute(`viewBox`,`0 0 ${o.globals.svgWidth} ${o.globals.svgHeight}`),this._printRestore.viewBoxAdded=!0,(a=(i=o.dom)==null?void 0:i.elWrap)==null||a.classList.add(`apexcharts-printing`);let e=this.el;e&&e.style&&(this._printRestore.minHeight=e.style.minHeight,e.style.minHeight=`0`)}}_afterPrint(){var e,t,n,r,i,a,o;if(!this._printRestore)return;let s=this.w,c=this._printRestore;if(this._printRestore=null,c.viewBoxAdded){(n=(t=(e=s.dom)==null?void 0:e.Paper)==null?void 0:t.node)==null||n.removeAttribute(`viewBox`),(i=(r=s.dom)==null?void 0:r.elWrap)==null||i.classList.remove(`apexcharts-printing`);let o=this.el;o&&o.style&&(o.style.minHeight=(a=c.minHeight)==null?``:a)}s.config.chart.width!==c.width&&(this.updateHelpers._updateOptions({chart:{width:c.width}},!1,!1,!1,!1),clearTimeout((o=s.globals.resizeTimer)==null?void 0:o))}_windowResize(){var e;clearTimeout((e=this.w.globals.resizeTimer)==null?void 0:e),this.w.globals.resizeTimer=window.setTimeout(()=>{let e=this.w.globals;if(this.core&&e.lastResizeSignature){let t=this.core.getResizeSignature();if(t.w===e.lastResizeSignature.w&&t.h===e.lastResizeSignature.h&&t.iw===e.lastResizeSignature.iw)return}e.resized=!0,e.dataChanged=!1,this.ctx.update()},150)}_windowResizeHandler(){var e;clearTimeout((e=this.w.globals.resizeTimer)==null?void 0:e);let{redrawOnWindowResize:t}=this.w.config.chart;typeof t==`function`&&(t=t()),t&&this._windowResize()}};u(pr,`perspectives`,null);let mr=pr;export{Animations as __apex_Animations,we as __apex_Animations_applyAnimationPolicy,Ce as __apex_Animations_applyProgressiveReveal,Te as __apex_Animations_computeStagger,Se as __apex_Animations_prefersReducedMotion,Base as __apex_Base,BrowserAPIs as __apex_BrowserAPIs_BrowserAPIs,Z as __apex_ChartFactory_getChartClass,X as __apex_ChartFactory_isCustom,qt as __apex_ChartFactory_register,Config as __apex_Config,j as __apex_Constants_LINE_HEIGHT_RATIO,M as __apex_Constants_NICE_SCALE_ALLOWED_MAG_MSD,N as __apex_Constants_NICE_SCALE_DEFAULT_TICKS,Core as __apex_Core,CoreUtils as __apex_CoreUtils,Crosshairs as __apex_Crosshairs,SSRClassList as __apex_DOMShim_SSRClassList,SSRDOMShim as __apex_DOMShim_SSRDOMShim,SSRElement as __apex_DOMShim_SSRElement,Data as __apex_Data,DataLabels as __apex_DataLabels,DateTime as __apex_DateTime,Defaults as __apex_Defaults,Environment as __apex_Environment_Environment,Events as __apex_Events,Fill as __apex_Fill,Filters as __apex_Filters,Formatters as __apex_Formatters,Globals as __apex_Globals,Graphics as __apex_Graphics,Markers as __apex_Markers,Options as __apex_Options,L as __apex_PathMorphing_arrayToPath,ne as __apex_PathMorphing_morphPaths,F as __apex_PathMorphing_parsePath,I as __apex_PathMorphing_pathBbox,PerformanceCache as __apex_PerformanceCache,Range as __apex_Range,Un as __apex_Resize_addResizeListener,Wn as __apex_Resize_removeResizeListener,Responsive as __apex_Responsive,SVGAnimationRunner as __apex_SVGAnimation_SVGAnimationRunner,ue as __apex_SVGAnimation_installAnimationMethods,SVGContainer as __apex_SVGContainer,vn as __apex_SVGDraggable_installDraggable,SVGElement as __apex_SVGElement,FilterBuilder as __apex_SVGFilter_FilterBuilder,SVGFilter as __apex_SVGFilter_SVGFilter,_n as __apex_SVGFilter_installFilterMethods,SVGGradient as __apex_SVGGradient_SVGGradient,SVGPattern as __apex_SVGPattern_SVGPattern,yn as __apex_SVGSelectable_installSelectable,Scales as __apex_Scales,Series as __apex_Series,Theme as __apex_Theme,Me as __apex_ThemePalettes_getThemePalettes,TimeScale as __apex_TimeScale,TitleSubtitle as __apex_TitleSubtitle,_ as __apex_Utils,Axes as __apex_axes_Axes,AxesUtils as __apex_axes_AxesUtils,Grid as __apex_axes_Grid,XAxis as __apex_axes_XAxis,YAxis as __apex_axes_YAxis,Scatter as __apex_charts_Scatter,Dimensions as __apex_dimensions_Dimensions,DimGrid as __apex_dimensions_Grid,Helpers as __apex_dimensions_Helpers,DimXAxis as __apex_dimensions_XAxis,DimYAxis as __apex_dimensions_YAxis,Destroy as __apex_helpers_Destroy,InitCtxVariables as __apex_helpers_InitCtxVariables,Localization as __apex_helpers_Localization,UpdateHelpers as __apex_helpers_UpdateHelpers,Box as __apex_index_Box,bn as __apex_index_SVG,Box as __apex_math_Box,Matrix as __apex_math_Matrix,Point as __apex_math_Point,P as __apex_math_SVGNS,AxesTooltip as __apex_tooltip_AxesTooltip,Intersect as __apex_tooltip_Intersect,Labels as __apex_tooltip_Labels,Marker as __apex_tooltip_Marker,Position as __apex_tooltip_Position,Tooltip as __apex_tooltip_Tooltip,Utils2 as __apex_tooltip_Utils,mr as default};

