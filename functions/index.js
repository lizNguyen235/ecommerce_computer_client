/* eslint-disable max-len */

const functions = require("firebase-functions/v1"); // Hoặc firebase-functions nếu bạn dùng SDK mới nhất
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// KHỞI TẠO FIREBASE ADMIN SDK
try {
  admin.initializeApp();
} catch (e) {
  // Firebase App đã được khởi tạo ở chỗ khác hoặc có lỗi
  console.log("Admin App already initialized or error:", e.message);
}

const db = admin.firestore();
// CẤU HÌNH NODEMAILER TRANSPORTER
// LƯU Ý QUAN TRỌNG: KHÔNG NÊN HARDCODE CREDENTIALS TRONG MÔI TRƯỜNG PRODUCTION.
// HÃY SỬ DỤNG FIREBASE FUNCTION CONFIGURATION:
// firebase functions:config:set gmail.email="your-email@gmail.com" gmail.password="your-app-password"
// Sau đó truy cập bằng: functions.config().gmail.email và functions.config().gmail.password
const GMAIL_EMAIL = "taikhoanlambai2025@gmail.com"; // <<== THAY BẰNG functions.config().gmail.email
const GMAIL_PASSWORD = "eyyk svzb kdro wdlu";      // <<== THAY BẰNG functions.config().gmail.password

let mailTransporter;
if (GMAIL_EMAIL && GMAIL_PASSWORD) {
  mailTransporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: GMAIL_EMAIL,
      pass: GMAIL_PASSWORD,
    },
  });
} else {
  console.error(
    "Gmail email hoặc password chưa được cung cấp. " +
    "Hãy cấu hình bằng `firebase functions:config:set gmail.email=\"YOUR_EMAIL\" gmail.password=\"YOUR_PASSWORD\"` " +
    "hoặc cung cấp trực tiếp trong code (không khuyến khích cho production)."
  );
}

// HÀM GỬI EMAIL CHUNG (Tương tự file của bạn)
async function sendEmailNotification(to, subject, htmlContent) {
  if (!mailTransporter) {
    console.error("Mail transporter chưa được khởi tạo. Không thể gửi email.");
    return; // Hoặc throw new Error("Mail transporter not initialized");
  }
  const mailOptions = {
    from: `"Tên Cửa Hàng Của Bạn" <${GMAIL_EMAIL}>`, // Thay "Tên Cửa Hàng Của Bạn"
    to,
    subject,
    html: htmlContent,
  };
  try {
    await mailTransporter.sendMail(mailOptions);
    console.log(`Email đã được gửi tới ${to} với chủ đề: ${subject}`);
  } catch (error) {
    console.error(`Lỗi khi gửi email tới ${to}:`, error);
    // Cân nhắc throw error để function gọi nó có thể xử lý
  }
}

// HÀM HELPER LẤY THÔNG TIN SẢN PHẨM (Tùy chọn, để email đẹp hơn)
async function getProductDetailsForEmail(productId) {
  try {
    const productDoc = await admin.firestore().collection("products").doc(productId).get();
    if (productDoc.exists) {
      const productData = productDoc.data();
      return {
        title: productData.title || "Sản phẩm không xác định",
        // thumbnail: productData.thumbnail || "", // Bỏ qua thumbnail cho đơn giản
      };
    }
    return null;
  } catch (error) {
    console.error(`Lỗi khi lấy chi tiết sản phẩm ${productId} cho email:`, error);
    return null;
  }
}


// -----------------------------------------------------------------------------
// FUNCTION: GỬI EMAIL XÁC NHẬN KHI CÓ ĐƠN HÀNG MỚI
// -----------------------------------------------------------------------------
exports.sendOrderConfirmationEmail = functions
  .region("asia-southeast1") // Chọn region phù hợp
  .firestore.document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const orderData = snap.data();
    const orderId = context.params.orderId;

    if (!orderData) {
      console.log(`Không có dữ liệu cho đơn hàng ${orderId}.`);
      return null;
    }

    const userId = orderData.userId;
    // Lấy thông tin từ shippingAddress
    const shippingName = orderData.shippingAddress?.name || "Valued Customer";
    const shippingPhone = orderData.shippingAddress?.phone || "N/A";
    const shippingFullAddress = orderData.shippingAddress?.address || "N/A";

    const totalAmount = orderData.totalAmount || 0;
    const orderItems = orderData.items || [];
    const orderDate = orderData.createdAt.toDate().toLocaleDateString("en-US", {
      year: "numeric", month: "long", day: "numeric", hour: "2-digit", minute: "2-digit",
    });

    let userEmailToNotify = null;

    // 1. Lấy email người dùng từ Firebase Authentication
    try {
      const userRecord = await admin.auth().getUser(userId);
      if (userRecord.email) {
        userEmailToNotify = userRecord.email;
      }
    } catch (authError) {
      console.warn(`Không tìm thấy user trong Authentication với UID ${userId} cho đơn hàng ${orderId}:`, authError.message);
    }

    // 2. Nếu không có từ Auth, thử lấy từ collection 'users'
    if (!userEmailToNotify) {
      try {
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        if (userDoc.exists && userDoc.data().email) {
          userEmailToNotify = userDoc.data().email;
          console.log(`Tìm thấy email cho UID ${userId} từ Firestore collection 'users'.`);
        }
      } catch (firestoreError) {
        console.warn(`Lỗi khi truy cập user document cho UID ${userId} trong Firestore:`, firestoreError.message);
      }
    }

    if (!userEmailToNotify) {
      console.error(`Không thể xác định địa chỉ email để gửi thông báo cho đơn hàng ${orderId} của user ${userId}.`);
      return null;
    }

    // Xây dựng chi tiết các sản phẩm cho email
    let itemsHtmlList = "";
    for (const item of orderItems) {
      // Giả sử item trong order đã có trường 'name' của sản phẩm
      // Nếu không, bạn cần getProductDetailsForEmail(item.productId)
      const productName = item.name || `Product (ID: ${item.productId.substring(0, 6)}...)`;
      const itemTotal = (item.price || 0) * (item.quantity || 0);

      itemsHtmlList += `
        <tr style="border-bottom: 1px solid #eee;">
          <td style="padding: 10px 5px; text-align: left;">${productName}</td>
          <td style="padding: 10px 5px; text-align: center;">${item.quantity || 0}</td>
          <td style="padding: 10px 5px; text-align: right;">${item.price ? item.price.toLocaleString("en-US", {style: "currency", currency: "USD"}) : "N/A"}</td>
          <td style="padding: 10px 5px; text-align: right;">${itemTotal.toLocaleString("en-US", {style: "currency", currency: "USD"})}</td>
        </tr>
      `;
    }

    // Nội dung HTML của email
    const emailHtmlContent = `
    <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333333; max-width: 600px; margin: 20px auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
      <div style="background-color: #4A90E2; color: white; padding: 25px 20px; text-align: center;">
        <h1 style="margin: 0; font-size: 26px; font-weight: 600;">Order Confirmation</h1>
      </div>
      <div style="padding: 25px 30px;">
        <p style="font-size: 16px;">Hello <strong>${shippingName}</strong>,</p>
        <p style="font-size: 16px;">Thank you for your order at <strong>Cửa hàng máy tính Quang Hưng</strong>. We have received your order and it is now being processed.</p>

        <div style="background-color: #f9f9f9; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <p style="margin: 5px 0; font-size: 16px;"><strong>Order ID:</strong> <span style="color: #4A90E2; font-weight: bold;">#${orderId}</span></p>
          <p style="margin: 5px 0; font-size: 16px;"><strong>Order Date:</strong> ${orderDate}</p>
        </div>

        <h3 style="border-bottom: 2px solid #4A90E2; padding-bottom: 10px; margin-top: 30px; margin-bottom: 10px; font-size: 20px; color: #4A90E2;">Shipping Information:</h3>
        <div style="margin-bottom: 20px; padding: 10px; border: 1px dashed #ccc; border-radius: 4px; background-color: #fdfdfd;">
          <p style="margin: 3px 0; font-size: 15px;"><strong>Recipient:</strong> ${shippingName}</p>
          <p style="margin: 3px 0; font-size: 15px;"><strong>Phone:</strong> ${shippingPhone}</p>
          <p style="margin: 3px 0; font-size: 15px;"><strong>Address:</strong> ${shippingFullAddress}</p>
        </div>

        <h3 style="border-bottom: 2px solid #4A90E2; padding-bottom: 10px; margin-top: 30px; margin-bottom: 20px; font-size: 20px; color: #4A90E2;">Order Details:</h3>
        <table style="width: 100%; border-collapse: collapse; margin-bottom: 25px; font-size: 15px;">
          <thead>
            <tr style="background-color: #f0f8ff;">
              <th style="padding: 12px 8px; text-align: left; border-bottom: 1px solid #ddd;">Product</th>
              <th style="padding: 12px 8px; text-align: center; border-bottom: 1px solid #ddd;">Qty</th>
              <th style="padding: 12px 8px; text-align: right; border-bottom: 1px solid #ddd;">Unit Price</th>
              <th style="padding: 12px 8px; text-align: right; border-bottom: 1px solid #ddd;">Total</th>
            </tr>
          </thead>
          <tbody>
            ${itemsHtmlList}
          </tbody>
        </table>
        <div style="text-align: right; margin-top: 25px; padding-top: 20px; border-top: 2px solid #eee;">
          <p style="font-size: 18px; margin: 8px 0; font-weight: bold;">Grand Total: <span style="color: #D9534F;">${totalAmount.toLocaleString("en-US", {style: "currency", currency: "USD"})}</span></p>
        </div>
        <p style="font-size: 16px; margin-top: 25px;">We will notify you once your order has been shipped. You can review your order details and track its status on your <a href="YOUR_WEBSITE_ORDER_TRACKING_URL/${orderId}" style="color: #4A90E2; text-decoration: none; font-weight: bold;">order management page</a>.</p>
        <p style="font-size: 16px;">If you have any questions, please do not hesitate to contact our support team.</p>
        <p style="font-size: 16px; margin-top: 30px;">Sincerely,<br/>The <strong>Cửa hàng máy tính Quang Hưng</strong> Team</p>
      </div>
      <div style="background-color: #f5f5f5; color: #888888; padding: 20px; text-align: center; font-size: 13px; border-top: 1px solid #e0e0e0;">
        <p style="margin:0;">© ${new Date().getFullYear()} Cửa hàng máy tính Quang Hưng. All rights reserved.</p>
        <p style="margin:5px 0 0 0;">Địa chỉ liên hệ của bạn | <a href="YOUR_WEBSITE_URL" style="color: #4A90E2; text-decoration: none;">Our Website</a></p>
      </div>
    </div>
    `;

    // Gửi email
    try {
      // Hàm sendEmailNotification đã được định nghĩa ở trên và sử dụng mailTransporter
      // Cập nhật chủ đề email và tên người gửi
      const emailSubject = `Order Confirmation #${orderId.substring(0,8)} from Cửa hàng máy tính Quang Hưng`;
      await sendEmailNotification(userEmailToNotify, emailSubject, emailHtmlContent); // Hàm sendEmailNotification cần được định nghĩa và sử dụng GMAIL_EMAIL đúng
      console.log(`Confirmation email for order ${orderId} sent successfully to ${userEmailToNotify}.`);
    } catch (emailError) {
      console.error(`Could not send confirmation email for order ${orderId} to ${userEmailToNotify}:`, emailError);
    }

    return null; // Kết thúc function
  });
// ===== TRIGGERED FUNCTIONS =====

// 1. Khi USER MỚI được tạo trong Firebase Authentication
exports.onNewUserCreated = functions.region("asia-southeast1")
  .auth.user().onCreate(async (user) => {
    console.log("New user created in Auth:", user.uid, user.email);

    // Cập nhật dashboardMetrics
    const metricsRef = db.collection("dashboardMetrics").doc("global");
    const dailyStatsId = new Date().toISOString().split('T')[0]; // YYYY-MM-DD
    const dailyStatsRef = db.collection("dailyStats").doc(dailyStatsId);

    try {
      await db.runTransaction(async (transaction) => {
        // Cập nhật dashboardMetrics
        transaction.set(metricsRef, {
          totalUsers: admin.firestore.FieldValue.increment(1),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        // Cập nhật dailyStats
        transaction.set(dailyStatsRef, {
          newUsers: admin.firestore.FieldValue.increment(1),
          date: admin.firestore.Timestamp.fromDate(new Date(new Date().setHours(0,0,0,0))), // Đầu ngày
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      });
      console.log(`Metrics updated for new user ${user.uid}`);
    } catch (error) {
      console.error(`Error updating metrics for new user ${user.uid}:`, error);
    }
    return null;
  });


// 2. Khi ORDER MỚI được tạo trong Firestore
exports.onNewOrderCreated = functions.region("asia-southeast1")
  .firestore.document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const orderData = snap.data();
    const orderId = context.params.orderId;

    if (!orderData) {
      console.log(`No data for new order ${orderId}.`);
      return null;
    }

    const totalAmount = orderData.totalAmount || 0;
    const items = orderData.items || [];
    const orderTimestamp = orderData.createdAt || admin.firestore.FieldValue.serverTimestamp(); // Dùng createdAt từ order

    // Cập nhật dashboardMetrics
    const metricsRef = db.collection("dashboardMetrics").doc("global");
    const dailyStatsId = (orderTimestamp.toDate ? orderTimestamp.toDate() : new Date()).toISOString().split('T')[0]; // YYYY-MM-DD dựa trên ngày đặt hàng
    const dailyStatsRef = db.collection("dailyStats").doc(dailyStatsId);

    try {
      await db.runTransaction(async (transaction) => {
        // Cập nhật dashboardMetrics
        transaction.set(metricsRef, {
          totalOrders: admin.firestore.FieldValue.increment(1),
          totalRevenue: admin.firestore.FieldValue.increment(totalAmount),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        // Cập nhật dailyStats
        const orderDateStartOfDay = orderTimestamp.toDate ? new Date(orderTimestamp.toDate().setHours(0,0,0,0)) : new Date(new Date().setHours(0,0,0,0));
        transaction.set(dailyStatsRef, {
          ordersCount: admin.firestore.FieldValue.increment(1),
          revenue: admin.firestore.FieldValue.increment(totalAmount),
          date: admin.firestore.Timestamp.fromDate(orderDateStartOfDay),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        // Cập nhật productSalesSummary cho từng item trong đơn hàng
        for (const item of items) {
          if (item && item.productId && item.quantity > 0) {
            const productSummaryRef = db.collection("productSalesSummary").doc(item.productId);
            transaction.set(productSummaryRef, {
              productId: item.productId,
              productName: item.name || "Unknown Product", // Lấy tên từ item của order
              totalQuantitySold: admin.firestore.FieldValue.increment(item.quantity),
              lastSaleDate: orderTimestamp, // Lưu thời gian bán cuối cùng
              // category: item.category || "Unknown", // Nếu bạn lưu category trong order item
            }, { merge: true });
          }
        }
      });
      console.log(`Metrics and product sales updated for new order ${orderId}`);
    } catch (error) {
      console.error(`Error updating metrics for new order ${orderId}:`, error);
    }
    return null;
  });


// ----- CÁC FUNCTIONS KHÁC TỪ FILE CỦA BẠN CÓ THỂ ĐẶT Ở ĐÂY -----
// Ví dụ:
// exports.scheduledDeleteUnverifiedUsers = functions.pubsub...
// exports.sendNewTaskNotification = functions.firestore...
// exports.sendTaskUpdateNotification = functions.firestore...
// exports.sendTaskDeleteNotification = functions.firestore...
// exports.scheduledDeleteOldInvitations = functions.pubsub...
// exports.sendGroupDeleteNotification = functions.firestore...
// exports.sendGroupRenameNotification = functions.firestore...