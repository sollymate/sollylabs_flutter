//const functions = require("firebase-functions");
//
//exports.redirectToDesktopOrWeb = functions.https.onRequest((req, res) => {
//    const desktopUri = "sollylabs_flutter://login-callback";
//    const webFallback = "https://sollylabs-flutter.web.app/login-callback";
//
//    // Check the User-Agent header to identify the desktop app
//    const userAgent = req.headers["user-agent"] || "";
//    const isDesktopApp = userAgent.includes("YourDesktopAppIdentifier");
//
//    if (isDesktopApp) {
//        // Redirect to the desktop app protocol
//        res.redirect(desktopUri);
//    } else {
//        // Redirect to the web app fallback
//        res.redirect(webFallback);
//    }
//});


/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
