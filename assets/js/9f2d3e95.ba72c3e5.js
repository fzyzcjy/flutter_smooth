"use strict";(self.webpackChunksmooth=self.webpackChunksmooth||[]).push([[1512],{3905:(e,t,n)=>{n.d(t,{Zo:()=>c,kt:()=>h});var r=n(7294);function i(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function o(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function a(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?o(Object(n),!0).forEach((function(t){i(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):o(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function s(e,t){if(null==e)return{};var n,r,i=function(e,t){if(null==e)return{};var n,r,i={},o=Object.keys(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||(i[n]=e[n]);return i}(e,t);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(r=0;r<o.length;r++)n=o[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(i[n]=e[n])}return i}var l=r.createContext({}),p=function(e){var t=r.useContext(l),n=t;return e&&(n="function"==typeof e?e(t):a(a({},t),e)),n},c=function(e){var t=p(e.components);return r.createElement(l.Provider,{value:t},e.children)},d={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},u=r.forwardRef((function(e,t){var n=e.components,i=e.mdxType,o=e.originalType,l=e.parentName,c=s(e,["components","mdxType","originalType","parentName"]),u=p(n),h=i,m=u["".concat(l,".").concat(h)]||u[h]||d[h]||o;return n?r.createElement(m,a(a({ref:t},c),{},{components:n})):r.createElement(m,a({ref:t},c))}));function h(e,t){var n=arguments,i=t&&t.mdxType;if("string"==typeof e||i){var o=n.length,a=new Array(o);a[0]=u;var s={};for(var l in t)hasOwnProperty.call(t,l)&&(s[l]=t[l]);s.originalType=e,s.mdxType="string"==typeof e?e:i,a[1]=s;for(var p=2;p<o;p++)a[p]=n[p];return r.createElement.apply(null,a)}return r.createElement.apply(null,n)}u.displayName="MDXCreateElement"},3304:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>l,contentTitle:()=>a,default:()=>d,frontMatter:()=>o,metadata:()=>s,toc:()=>p});var r=n(7462),i=(n(7294),n(3905));const o={},a="SmoothListView",s={unversionedId:"design/drop-in/list-view",id:"design/drop-in/list-view",title:"SmoothListView",description:"To use the package, there is no need to understand this section since it is implementation details. This section is for those who are interested in knowing what happens under the hood.",source:"@site/docs/design/drop-in/list-view.md",sourceDirName:"design/drop-in",slug:"/design/drop-in/list-view",permalink:"/flutter_smooth/design/drop-in/list-view",draft:!1,editUrl:"https://github.com/fzyzcjy/flutter_smooth/tree/master/website/docs/design/drop-in/list-view.md",tags:[],version:"current",frontMatter:{},sidebar:"tutorialSidebar",previous:{title:"SmoothMaterialPageRoute",permalink:"/flutter_smooth/design/drop-in/page-route"},next:{title:"Insight",permalink:"/flutter_smooth/insight/"}},l={},p=[],c={toc:p};function d(e){let{components:t,...n}=e;return(0,i.kt)("wrapper",(0,r.Z)({},c,n,{components:t,mdxType:"MDXLayout"}),(0,i.kt)("h1",{id:"smoothlistview"},"SmoothListView"),(0,i.kt)("admonition",{type:"info"},(0,i.kt)("p",{parentName:"admonition"},"To use the package, there is no need to understand this section since it is implementation details. This section is for those who are interested in knowing what happens under the hood.")),(0,i.kt)("p",null,"The core code is simple:"),(0,i.kt)("pre",null,(0,i.kt)("code",{parentName:"pre",className:"language-dart"},"return SmoothBuilder(\n  builder: (context, child) => SmoothShift(...),\n  child: ListView(...),\n);\n")),(0,i.kt)("p",null,"When the user is dragging ",(0,i.kt)("inlineCode",{parentName:"p"},"ListView"),", the ",(0,i.kt)("inlineCode",{parentName:"p"},"_SmoothShiftSourcePointerEvent")," will listen to those ",(0,i.kt)("inlineCode",{parentName:"p"},"PointerMoveEvent")," (via a normal ",(0,i.kt)("inlineCode",{parentName:"p"},"Listener")," widget), and provide proper shifting."),(0,i.kt)("p",null,"When the user has released the finger, i.e. ",(0,i.kt)("inlineCode",{parentName:"p"},"ListView")," is now ballistic shifting by inertia, the ",(0,i.kt)("inlineCode",{parentName:"p"},"_SmoothShiftSourceBallistic")," comes and provide proper shifting during preempt rendering."),(0,i.kt)("p",null,"When the user is releasing his finger (",(0,i.kt)("inlineCode",{parentName:"p"},"PointerUpEvent"),'), we can implement is just like the two cases above. However, to illustrate the ability of the "Brake" mechanism, I trigger a brake when this happens.'))}d.isMDXComponent=!0}}]);