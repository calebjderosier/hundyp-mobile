// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
import functions from "firebase-functions";
import admin from "firebase-admin";

admin.initializeApp();

// Example function to send notifications
exports.sendNotification = functions.https.onCall(async (data, context) => {
  const message = {
    notification: {
      title: "Hundy P Alert",
      body: "Oh, I'm fucking coming!",
    },
  };

  try {
    // Get all tokens from Firestore collection
    const tokensSnapshot = await admin
      .firestore()
      .collection("pushNotificationTokens")
      .get();
    const tokens = tokensSnapshot.docs.map((doc) => doc.data().fcmToken);

    if (tokens.length === 0) {
      console.log("No tokens available.");
      return { success: false, message: "No tokens found." };
    }

    // Send a notification to all tokens
    const response = await admin
      .messaging()
      .sendEachForMulticast({ ...message, tokens });

    console.log("Notifications sent:", response);
    return { success: true, message: "Notifications sent successfully." };
  } catch (error) {
    console.error("Error sending notifications:", error);
    return { success: false, message: "Error sending notifications." };
  }
});
