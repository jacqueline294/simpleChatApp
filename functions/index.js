const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendChatNotification = functions.region('us-central1') // Example region, adjust if needed
    .firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
        const messageData = snap.data();
        if (!messageData) {
            console.log("No message data found.");
            return null;
        }

        const senderId = messageData.senderId;
        const messageText = messageData.text ? (messageData.text.length > 100 ? messageData.text.substring(0, 97) + "..." : messageData.text) : (messageData.imageUrl ? "Sent an image" : "Sent a file");

        const chatId = context.params.chatId;
        const userIdsInChat = chatId.split('_'); // Assumes chatId is "userId1_userId2" for 1-on-1
        
        let recipientId = null;
        if (userIdsInChat.length === 2) { // Basic 1-on-1 chat logic
            recipientId = (userIdsInChat[0] === senderId) ? userIdsInChat[1] : userIdsInChat[0];
        } else {
            // Placeholder for group chat logic: If it's not a 1-on-1 ID, assume it's a group.
            // This part needs actual implementation based on how groups are structured.
            // For now, it will only work for 1-on-1 chats with the specific chatId format.
            console.log(`ChatId ${chatId} does not fit "userId1_userId2" format. Group logic needed or ensure 1-on-1 chatIds are formatted this way.`);
            // Attempt to read participants from the chat document if it's a group chat
            // This requires the 'chats/{chatId}' document to have a 'participants' array field.
            const chatDoc = await admin.firestore().collection('chats').doc(chatId).get();
            if (chatDoc.exists && chatDoc.data().participants && Array.isArray(chatDoc.data().participants)) {
                const participants = chatDoc.data().participants;
                // Send to all participants except the sender
                const recipientIds = participants.filter(uid => uid !== senderId);
                if (recipientIds.length > 0) {
                     // Fetch sender's name (once for all recipients)
                    let senderName = 'Someone';
                    try {
                        const senderUserDoc = await admin.firestore().collection('users').doc(senderId).get();
                        if (senderUserDoc.exists && senderUserDoc.data().name) {
                            senderName = senderUserDoc.data().name;
                        }
                    } catch (error) {
                        console.error('Error fetching sender name:', error);
                    }
                    
                    const tokens = [];
                    for (const rId of recipientIds) {
                        const userDoc = await admin.firestore().collection('users').doc(rId).get();
                        if (userDoc.exists && userDoc.data().fcmToken) {
                            tokens.push(userDoc.data().fcmToken);
                        }
                    }

                    if (tokens.length > 0) {
                        const payload = {
                            notification: {
                                title: `New message in group from ${senderName}`, // Adjust title for group
                                body: messageText,
                                sound: 'default',
                                badge: '1' 
                            },
                            data: { chatId: chatId, senderId: senderId, isGroupChat: "true" }
                        };
                        console.log("Sending to tokens:", tokens);
                        return admin.messaging().sendToDevice(tokens, payload);
                    }
                }
            } else {
                 console.log(`ChatId ${chatId} is not 1-on-1 and no participants field found. Cannot determine recipients.`);
                 return null;
            }
            return null; // Exit if not 1-on-1 and no group logic matched
        }

        if (!recipientId) {
            console.log('Could not determine recipientId for 1-on-1 chat with chatId:', chatId);
            return null;
        }

        // Fetch sender's name
        let senderName = 'Someone';
        try {
            const senderUserDoc = await admin.firestore().collection('users').doc(senderId).get();
            if (senderUserDoc.exists && senderUserDoc.data().name) {
                senderName = senderUserDoc.data().name;
            }
        } catch (error) {
            console.error('Error fetching sender name for 1-on-1:', error);
        }
        
        // Get recipient's FCM token for 1-on-1 chat
        const recipientUserDoc = await admin.firestore().collection('users').doc(recipientId).get();
        if (!recipientUserDoc.exists || !recipientUserDoc.data().fcmToken) {
            console.log('Recipient does not exist or has no FCM token:', recipientId);
            return null;
        }
        const fcmToken = recipientUserDoc.data().fcmToken;

        const payload = {
            notification: {
                title: `New message from ${senderName}`,
                body: messageText,
                sound: 'default',
                badge: '1' 
            },
            data: { chatId: chatId, senderId: senderId, isGroupChat: "false" }
        };
        
        console.log(`Sending 1-on-1 notification to token: ${fcmToken} for recipient: ${recipientId}`);
        try {
            const response = await admin.messaging().sendToDevice(fcmToken, payload);
            console.log('Successfully sent 1-on-1 message:', response);
            response.results.forEach((result, index) => {
                const error = result.error;
                if (error) {
                    console.error('Failure sending 1-on-1 notification to', fcmToken, error);
                    if (error.code === 'messaging/invalid-registration-token' ||
                        error.code === 'messaging/registration-token-not-registered') {
                        // Consider removing the token from user's profile
                        // admin.firestore().collection('users').doc(recipientId).update({fcmToken: admin.firestore.FieldValue.delete()});
                    }
                }
            });
        } catch (error) {
            console.log('Error sending 1-on-1 message:', error);
        }
        return null;
    });
