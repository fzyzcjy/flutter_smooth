console.log('my_worker.js start');

// Download main.dart.js
_flutter.loader.loadEntrypoint({
    serviceWorker: {
        serviceWorkerVersion: serviceWorkerVersion,
    }
}).then(function (engineInitializer) {
    console.log(`my_worker.js see engineInitializer=${engineInitializer}`);
    return engineInitializer.initializeEngine();
}).then(function (appRunner) {
    console.log(`my_worker.js see appRunner=${appRunner}`);
    return appRunner.runApp();
});
