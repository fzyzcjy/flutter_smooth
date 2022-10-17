"use strict";(self.webpackChunksmooth=self.webpackChunksmooth||[]).push([[880],{3905:(e,t,r)=>{r.d(t,{Zo:()=>u,kt:()=>m});var n=r(7294);function i(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function a(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function o(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?a(Object(r),!0).forEach((function(t){i(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):a(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function l(e,t){if(null==e)return{};var r,n,i=function(e,t){if(null==e)return{};var r,n,i={},a=Object.keys(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||(i[r]=e[r]);return i}(e,t);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);for(n=0;n<a.length;n++)r=a[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(i[r]=e[r])}return i}var s=n.createContext({}),c=function(e){var t=n.useContext(s),r=t;return e&&(r="function"==typeof e?e(t):o(o({},t),e)),r},u=function(e){var t=c(e.components);return n.createElement(s.Provider,{value:t},e.children)},f={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},p=n.forwardRef((function(e,t){var r=e.components,i=e.mdxType,a=e.originalType,s=e.parentName,u=l(e,["components","mdxType","originalType","parentName"]),p=c(r),m=i,h=p["".concat(s,".").concat(m)]||p[m]||f[m]||a;return r?n.createElement(h,o(o({ref:t},u),{},{components:r})):n.createElement(h,o({ref:t},u))}));function m(e,t){var r=arguments,i=t&&t.mdxType;if("string"==typeof e||i){var a=r.length,o=new Array(a);o[0]=p;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l.mdxType="string"==typeof e?e:i,o[1]=l;for(var c=2;c<a;c++)o[c]=r[c];return n.createElement.apply(null,o)}return n.createElement.apply(null,r)}p.displayName="MDXCreateElement"},760:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>s,contentTitle:()=>o,default:()=>f,frontMatter:()=>a,metadata:()=>l,toc:()=>c});var n=r(7462),i=(r(7294),r(3905));const a={},o="Result from tracing",l={unversionedId:"benchmark/analyze/linearity/tracing",id:"benchmark/analyze/linearity/tracing",title:"Result from tracing",description:"By using the visualize_scroll.py script, we see the following figure. Shortly speaking, the blue curve is the time-vs-offset, and the orange curve is the time-vs-delta-offset, i.e. time-vs-velocity.",source:"@site/docs/benchmark/analyze/linearity/tracing.md",sourceDirName:"benchmark/analyze/linearity",slug:"/benchmark/analyze/linearity/tracing",permalink:"/flutter_smooth/benchmark/analyze/linearity/tracing",draft:!1,editUrl:"https://github.com/fzyzcjy/flutter_smooth/tree/master/website/docs/benchmark/analyze/linearity/tracing.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Result from video",permalink:"/flutter_smooth/benchmark/analyze/linearity/video"},next:{title:"Jank statistics",permalink:"/flutter_smooth/benchmark/analyze/jank-statistics/"}},s={},c=[],u={toc:c};function f(e){let{components:t,...a}=e;return(0,i.kt)("wrapper",(0,n.Z)({},u,a,{components:t,mdxType:"MDXLayout"}),(0,i.kt)("h1",{id:"result-from-tracing"},"Result from tracing"),(0,i.kt)("p",null,"By using the ",(0,i.kt)("inlineCode",{parentName:"p"},"visualize_scroll.py")," script, we see the following figure. Shortly speaking, the blue curve is the time-vs-offset, and the orange curve is the time-vs-delta-offset, i.e. time-vs-velocity."),(0,i.kt)("p",null,(0,i.kt)("img",{src:r(8468).Z,width:"1475",height:"890"})),(0,i.kt)("p",null,"There are a few interesting results from it:"),(0,i.kt)("ul",null,(0,i.kt)("li",{parentName:"ul"},"At ~7.1s, The velocity suddenly becomes zero for one frame, when the user releases the finger (i.e. ",(0,i.kt)("inlineCode",{parentName:"li"},"PointerUpEvent"),"). This is a bug of Flutter: ",(0,i.kt)("a",{parentName:"li",href:"https://github.com/flutter/flutter/issues/113494"},"https://github.com/flutter/flutter/issues/113494")),(0,i.kt)("li",{parentName:"ul"},"At ~8.2s, there is an abrupt velocity change. This is also a bug of Flutter: ",(0,i.kt)("a",{parentName:"li",href:"https://github.com/flutter/flutter/issues/113424"},"https://github.com/flutter/flutter/issues/113424"),"."),(0,i.kt)("li",{parentName:"ul"},"At 5.5-7.1s, the time-vs-velocity curve is not very smooth. This is because it is purely driven by human touch events, where it is just impossible to be very smooth. On the contrary, looking at the curve driven by ballistic ",(0,i.kt)("inlineCode",{parentName:"li"},"Simulation")," in 7.1s-8.2s, it is smooth.")),(0,i.kt)("p",null,"Except for those points (which are not problem of this library), the curve satisfies the linearity definition well without the need of explanations."))}f.isMDXComponent=!0},8468:(e,t,r)=>{r.d(t,{Z:()=>n});const n=r.p+"assets/images/analyze_linearlity_tracing-11d0c9213039bf1533938f4f86d3d814.png"}}]);