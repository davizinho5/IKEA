var profile = {

    // The JavaScript code will get minimized into layer files.
    layers: {
        "equationrenderer/equationrenderer": {
            copyright: "copyright.txt",
            include: [
                "equationrenderer/MathRenderer"
            ],
            exclude: [
                "dojo/dojo",
                "equationrenderer/browsercheck"
            ]
        },
        // dojo bootstrapper
        "dojo/dojo": {
            copyright: "copyright.txt",
            include: [
                // Include Web Widget modules here
                "MW/equations/renderer/StandaloneEqnRenderer",

                "dojo/dojo",
                "dojo/dom",
                "dojo/domReady"
            ],
            customBase: true,
            boot: true
        }
    }
};
