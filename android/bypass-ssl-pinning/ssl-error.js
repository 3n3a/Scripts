Java.perform(function () {

const UnverifiedCertError = Java.use('javax.net.ssl.SSLPeerUnverifiedException');
UnverifiedCertError.$init.implementation = function (str) {

        const stackTrace = Java.use('java.lang.Thread').currentThread().getStackTrace();
        const exceptionStackIndex = stackTrace.findIndex(stack =>
            stack.getClassName() === "javax.net.ssl.SSLPeerUnverifiedException"
        );
        const callingFunctionStack = stackTrace[exceptionStackIndex + 1];

        const className = callingFunctionStack.getClassName();
        const methodName = callingFunctionStack.getMethodName();
        console.log(`      =================`);
        console.log(`      Debugging Stack Trace for SSLPeerUnverifiedException`);
        console.log(`      Thrown by ${className}->${methodName}`);
    };

        try {
            // Bypass OkHTTPv3 {4}
            const okhttp3_Activity_4 = Java.use('okhttp3.CertificatePinner');
            okhttp3_Activity_4.check$okhttp.overload('java.lang.String', 'kotlin.jvm.functions.Function0').implementation = function(a, b) {
                console.log('  --> Bypassing OkHTTPv3 ($okhttp): ' + a);
                return;
            };
            console.log('[+] OkHTTPv3 ($okhttp)');
        } catch (err) {
            console.log('[ ] OkHTTPv3 ($okhttp)');
        }
});
