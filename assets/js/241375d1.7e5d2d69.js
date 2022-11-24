"use strict";(self.webpackChunksmooth=self.webpackChunksmooth||[]).push([[3260],{3905:(e,t,r)=>{r.d(t,{Zo:()=>u,kt:()=>f});var n=r(7294);function a(e,t,r){return t in e?Object.defineProperty(e,t,{value:r,enumerable:!0,configurable:!0,writable:!0}):e[t]=r,e}function o(e,t){var r=Object.keys(e);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(e);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),r.push.apply(r,n)}return r}function i(e){for(var t=1;t<arguments.length;t++){var r=null!=arguments[t]?arguments[t]:{};t%2?o(Object(r),!0).forEach((function(t){a(e,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(r)):o(Object(r)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(r,t))}))}return e}function s(e,t){if(null==e)return{};var r,n,a=function(e,t){if(null==e)return{};var r,n,a={},o=Object.keys(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||(a[r]=e[r]);return a}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(n=0;n<o.length;n++)r=o[n],t.indexOf(r)>=0||Object.prototype.propertyIsEnumerable.call(e,r)&&(a[r]=e[r])}return a}var l=n.createContext({}),c=function(e){var t=n.useContext(l),r=t;return e&&(r="function"==typeof e?e(t):i(i({},t),e)),r},u=function(e){var t=c(e.components);return n.createElement(l.Provider,{value:t},e.children)},p={inlineCode:"code",wrapper:function(e){var t=e.children;return n.createElement(n.Fragment,{},t)}},m=n.forwardRef((function(e,t){var r=e.components,a=e.mdxType,o=e.originalType,l=e.parentName,u=s(e,["components","mdxType","originalType","parentName"]),m=c(r),f=a,y=m["".concat(l,".").concat(f)]||m[f]||p[f]||o;return r?n.createElement(y,i(i({ref:t},u),{},{components:r})):n.createElement(y,i({ref:t},u))}));function f(e,t){var r=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var o=r.length,i=new Array(o);i[0]=m;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s.mdxType="string"==typeof e?e:a,i[1]=s;for(var c=2;c<o;c++)i[c]=r[c];return n.createElement.apply(null,i)}return n.createElement.apply(null,r)}m.displayName="MDXCreateElement"},3456:(e,t,r)=>{r.r(t),r.d(t,{assets:()=>l,contentTitle:()=>i,default:()=>p,frontMatter:()=>o,metadata:()=>s,toc:()=>c});var n=r(7462),a=(r(7294),r(3905));const o={},i="Result",s={unversionedId:"benchmark/analyze/jank-statistics/result",id:"benchmark/analyze/jank-statistics/result",title:"Result",description:"From video",source:"@site/docs/benchmark/analyze/jank-statistics/result.md",sourceDirName:"benchmark/analyze/jank-statistics",slug:"/benchmark/analyze/jank-statistics/result",permalink:"/flutter_smooth/benchmark/analyze/jank-statistics/result",draft:!1,editUrl:"https://github.com/fzyzcjy/flutter_smooth/tree/master/website/docs/benchmark/analyze/jank-statistics/result.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"Definition",permalink:"/flutter_smooth/benchmark/analyze/jank-statistics/definition"},next:{title:"Overhead",permalink:"/flutter_smooth/benchmark/analyze/overhead/"}},l={},c=[{value:"From video",id:"from-video",level:2},{value:"From tracing",id:"from-tracing",level:2}],u={toc:c};function p(e){let{components:t,...r}=e;return(0,a.kt)("wrapper",(0,n.Z)({},u,r,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"result"},"Result"),(0,a.kt)("h2",{id:"from-video"},"From video"),(0,a.kt)("p",null,"By analysis in ",(0,a.kt)("a",{parentName:"p",href:"../fps/video"},"the previous section"),", there are only 5 trivial janks, zero nontrivial janks, and longest jank is only 16.67ms. Therefore, it seems that user does not face any annoying long janks."),(0,a.kt)("h2",{id:"from-tracing"},"From tracing"),(0,a.kt)("p",null,"By analysis in ",(0,a.kt)("a",{parentName:"p",href:"../fps/tracing"},"the previous section"),", there is no jank at all."))}p.isMDXComponent=!0}}]);