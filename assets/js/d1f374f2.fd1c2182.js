"use strict";(self.webpackChunksmooth=self.webpackChunksmooth||[]).push([[310],{3905:(e,t,n)=>{n.d(t,{Zo:()=>m,kt:()=>d});var r=n(7294);function o(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function i(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){o(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,r,o=function(e,t){if(null==e)return{};var n,r,o={},a=Object.keys(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(o[n]=e[n])}return o}var s=r.createContext({}),c=function(e){var t=r.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):i(i({},t),e)),n},m=function(e){var t=c(e.components);return r.createElement(s.Provider,{value:t},e.children)},p={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},h=r.forwardRef((function(e,t){var n=e.components,o=e.mdxType,a=e.originalType,s=e.parentName,m=l(e,["components","mdxType","originalType","parentName"]),h=c(n),d=o,f=h["".concat(s,".").concat(d)]||h[d]||p[d]||a;return n?r.createElement(f,i(i({ref:t},m),{},{components:n})):r.createElement(f,i({ref:t},m))}));function d(e,t){var n=arguments,o=t&&t.mdxType;if("string"==typeof e||o){var a=n.length,i=new Array(a);i[0]=h;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l.mdxType="string"==typeof e?e:o,i[1]=l;for(var c=2;c<a;c++)i[c]=n[c];return r.createElement.apply(null,i)}return r.createElement.apply(null,n)}h.displayName="MDXCreateElement"},1376:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>s,contentTitle:()=>i,default:()=>p,frontMatter:()=>a,metadata:()=>l,toc:()=>c});var r=n(7462),o=(n(7294),n(3905));const a={},i="FPS is 30 (not 59) when 16.67+0.01ms",l={unversionedId:"benchmark/pitfall/half-fps",id:"benchmark/pitfall/half-fps",title:"FPS is 30 (not 59) when 16.67+0.01ms",description:"It will immediately drop to 30FPS even if the frame is only 0.01ms longer than 16.67ms. Indeed this problem is unrelated to this package, because the proposed method will not be affected by this and will be (e.g.) 59FPS. However, it may be helpful to discuss here to avoid wrongly understand the metrics of the classical Flutter and other optimization methods.",source:"@site/docs/benchmark/pitfall/half-fps.md",sourceDirName:"benchmark/pitfall",slug:"/benchmark/pitfall/half-fps",permalink:"/flutter_smooth/benchmark/pitfall/half-fps",draft:!1,editUrl:"https://github.com/fzyzcjy/flutter_smooth/tree/master/docs/benchmark/pitfall/half-fps.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Pitfalls",permalink:"/flutter_smooth/benchmark/pitfall/"},next:{title:'Undetected jank and "jump" when latency changes',permalink:"/flutter_smooth/benchmark/pitfall/latency-change"}},s={},c=[],m={toc:c};function p(e){let{components:t,...n}=e;return(0,o.kt)("wrapper",(0,r.Z)({},m,n,{components:t,mdxType:"MDXLayout"}),(0,o.kt)("h1",{id:"fps-is-30-not-59-when-1667001ms"},"FPS is 30 (not 59) when 16.67+0.01ms"),(0,o.kt)("p",null,"It will immediately drop to 30FPS even if the frame is only 0.01ms longer than 16.67ms. Indeed this problem is unrelated to this package, because the proposed method will ",(0,o.kt)("strong",{parentName:"p"},"not")," be affected by this and will be (e.g.) 59FPS. However, it may be helpful to discuss here to avoid wrongly understand the metrics of the classical Flutter and other optimization methods."),(0,o.kt)("p",null,"To simplify math, suppose each frame needs 16.67+0.01ms and continue for one second. Then, classical Flutter (and some other optimization approaches discussed in the ",(0,o.kt)("a",{parentName:"p",href:"https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit#heading=h.enm17io2vqom"},"design doc"),") will miss half of the vsync, i.e. will only get vsync per 33.33ms. Therefore, they will simply run the pipeline per 33.33ms, which is 30FPS."),(0,o.kt)("p",null,"Remark: The \u201caverage FPS\u201d in DevTools ",(0,o.kt)("a",{parentName:"p",href:"https://github.com/flutter/devtools/issues/4522"},"seems to be wrong")," for such cases."),(0,o.kt)("p",null,"Remark: Given this discussion, when reading something like \u201c17ms\u201d in the \u201c",(0,o.kt)("inlineCode",{parentName:"p"},"*_frame_build_time_millis"),"\u201d in benchmark results, it indeed means a completely different end-user feeling (30FPS vs 59FPS)."),(0,o.kt)("admonition",{type:"caution"},(0,o.kt)("p",{parentName:"admonition"},"Takeaway:"),(0,o.kt)("ol",{parentName:"admonition"},(0,o.kt)("li",{parentName:"ol"},"Do not believe ",(0,o.kt)("inlineCode",{parentName:"li"},"average FPS")," in DevTools."),(0,o.kt)("li",{parentName:"ol"},(0,o.kt)("inlineCode",{parentName:"li"},"*_frame_build_time_millis"),' being something like "17ms", means 30FPS, not 59FPS.'))),(0,o.kt)("p",null,"(Firstly discussed in the ",(0,o.kt)("a",{parentName:"p",href:"https://docs.google.com/document/d/1FuNcBvAPghUyjeqQCOYxSt6lGDAQ1YxsNlOvrUx0Gko/edit#heading=h.enm17io2vqom"},"design doc"),")"))}p.isMDXComponent=!0}}]);