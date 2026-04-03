const express   = require('express');
const router    = express.Router();
const auth      = require('../middleware/auth');
const User      = require('../models/User');
const FloodData = require('../models/FloodData');
const { sendPendingAlerts } = require('../services/notificationService');
const fetch     = require('node-fetch');

// ── VAPID KEY ───────────────────────────────────────────────
router.get('/vapid-key', (_, res) => {
  res.json({ publicKey: process.env.VAPID_PUBLIC_KEY || '' });
});

// ── SUBSCRIBE PUSH ──────────────────────────────────────────
router.post('/subscribe', auth, async (req, res) => {
  try {
    const { subscription, fcmToken } = req.body;

    await User.findOneAndUpdate(
      { uid: req.user.uid },
      {
        'notifications.pushSubscription': subscription || null,
        'notifications.fcmToken': fcmToken || '',
        'notifications.push': true,
      },
      { upsert: true }
    );

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── TEST NOTIFICATION ───────────────────────────────────────
router.post('/test', async (req, res) => {
  try {
    await sendPendingAlerts(true);
    res.json({ success: true, message: 'ส่ง notification แล้ว' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── SIMULATE FLOOD ──────────────────────────────────────────
router.post('/simulate', async (req, res) => {
  try {
    const { districtId, status } = req.body;

    const DISTRICTS = {
      mueang:      { name: 'เมืองชลบุรี',  lat: 13.3611, lng: 100.9847 },
      banbueng:    { name: 'บ้านบึง',       lat: 13.2456, lng: 101.1057 },
      nongya:      { name: 'หนองใหญ่',      lat: 13.1556, lng: 101.2031 },
      banglamung:  { name: 'บางละมุง',      lat: 12.9236, lng: 100.8775 },
      phantong:    { name: 'พานทอง',        lat: 13.4501, lng: 101.1155 },
      phanasnikom: { name: 'พนัสนิคม',      lat: 13.4498, lng: 101.1842 },
      sriracha:    { name: 'ศรีราชา',       lat: 13.1282, lng: 100.9280 },
      kosichang:   { name: 'เกาะสีชัง',     lat: 13.1518, lng: 100.8044 },
      sattahip:    { name: 'สัตหีบ',        lat: 12.6617, lng: 100.9015 },
      borthong:    { name: 'บ่อทอง',        lat: 13.3045, lng: 101.2888 },
      kochan:      { name: 'เกาะจันทร์',    lat: 13.5201, lng: 101.2102 },
    };

    const d = DISTRICTS[districtId];
    if (!d) return res.status(400).json({ error: 'ไม่พบอำเภอนี้' });

    const waterLevel = status === 'flood' ? 95 : status === 'risk' ? 65 : 10;
    const rainfall   = status === 'flood' ? 45 : status === 'risk' ? 20 : 2;

    const prev = await FloodData
      .findOne({ districtId })
      .sort({ fetchedAt: -1 })
      .select('status');

    await FloodData.create({
      districtId,
      districtName: d.name,
      status,
      prevStatus:   prev?.status || 'safe',
      waterLevel,
      rainfall,
      temperature:  30,
      humidity:     80,
      windSpeed:    10,
      source:       'simulated-test',
      fetchedAt:    new Date(),
    });

    await sendPendingAlerts(false);

    res.json({
      success: true,
      message: `จำลอง ${d.name} → ${status} สำเร็จ`,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── LINE PUSH MESSAGE ───────────────────────────────────────
router.post('/line-bot', async (req, res) => {
  try {
    const { userId, message } = req.body;
    const token = process.env.LINE_CHANNEL_ACCESS_TOKEN;

    if (!token) {
      return res.status(500).json({ error: 'LINE_CHANNEL_ACCESS_TOKEN not set' });
    }

    const targetId = userId || process.env.LINE_USER_ID;
    if (!targetId) {
      return res.status(400).json({ error: 'userId required' });
    }

    const response = await fetch('https://api.line.me/v2/bot/message/push', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type':  'application/json',
      },
      body: JSON.stringify({
        to: targetId,
        messages: [{
          type: 'text',
          text: message || 'ทดสอบส่งข้อความ'
        }],
      }),
    });

    const data = await response.text();
    console.log("LINE PUSH:", data);

    res.json({ success: true });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── LINE WEBHOOK ────────────────────────────────────────────
router.post('/line-webhook', async (req, res) => {
  console.log("🔥 WEBHOOK HIT");
  console.log("BODY:", JSON.stringify(req.body, null, 2));

  try {
    const events = req.body.events || [];

    for (const event of events) {
      console.log("EVENT:", event.type);

      const userId = event.source?.userId;
      console.log("USER ID:", userId);

      if (!userId) continue;

      if (event.type === 'follow') {
        console.log("🎯 FOLLOW EVENT");

        // 🔥 DEBUG TOKEN
        console.log("TOKEN:", process.env.LINE_CHANNEL_ACCESS_TOKEN?.slice(0, 10));
        console.log("TOKEN LENGTH:", process.env.LINE_CHANNEL_ACCESS_TOKEN?.length);

        const response = await fetch('https://api.line.me/v2/bot/message/reply', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${process.env.LINE_CHANNEL_ACCESS_TOKEN}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            replyToken: event.replyToken,
            messages: [{
              type: 'text',
              text: `ยินดีต้อนรับ 🎉\n\nUser ID ของคุณ:\n${userId}\n\nนำไปใส่ในเว็บเพื่อรับการแจ้งเตือนได้เลย`
            }]
          })
        });

        const data = await response.text();
        console.log("LINE REPLY:", data);
      }
    }

    res.json({ success: true });

  } catch (err) {
    console.error('[Webhook ERROR]', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
