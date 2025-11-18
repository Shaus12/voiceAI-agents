module.exports = {

"[project]/sentry.server.config.ts [instrumentation] (ecmascript)": ((__turbopack_context__) => {
"use strict";

var { g: global, __dirname } = __turbopack_context__;
{
// This file configures the initialization of Sentry on the server.
// The config you add here will be used whenever the server handles a request.
// https://docs.sentry.io/platforms/javascript/guides/nextjs/
__turbopack_context__.s({});
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f40$sentry$2f$nextjs$2f$build$2f$cjs$2f$index$2e$server$2e$js__$5b$instrumentation$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/@sentry/nextjs/build/cjs/index.server.js [instrumentation] (ecmascript)");
;
// Only initialize Sentry if explicitly enabled and DSN is provided
const enableSentry = process.env.NEXT_PUBLIC_SENTRY_DSN;
if (enableSentry) {
    (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f40$sentry$2f$nextjs$2f$build$2f$cjs$2f$index$2e$server$2e$js__$5b$instrumentation$5d$__$28$ecmascript$29$__["init"])({
        dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
        // Setting this option to true will print useful information to the console while you're setting up Sentry.
        debug: false,
        enabled: process.env.NEXT_PUBLIC_NODE_ENV === 'production'
    });
    console.log('Sentry initialized for server-side error tracking');
} else {
    console.log('Sentry disabled on server (NEXT_PUBLIC_ENABLE_SENTRY=false or DSN not configured)');
}
}}),

};

//# sourceMappingURL=sentry_server_config_ts_766cf762._.js.map