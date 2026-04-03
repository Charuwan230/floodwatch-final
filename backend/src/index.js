require('dotenv').config();

const express  = require('express');
const cors     = require('cors');
const mongoose = require('mongoose');
const fetch    = require('node-fetch');

const app = express();

app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB error:', err));

// 🔥 LINE WEBHOOK
app.post('/webhook', async (req, res) => {
  try {
    const events = req.body.events;

    if (!events) return res.sendStatus(200);

    for (const event of events) {
      if (event.type === 'message') {
        const userId = event.source.userId;

        console.log('📩 LINE USER ID:', userId);

        await fetch('https://api.line.me/v2/bot/message/reply', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${process.env.LINE_CHANNEL_ACCESS_TOKEN}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            replyToken: event.replyToken,
            messages: [{
              type: 'text',
              text: `User ID: ${userId}`,
            }],
          }),
        });
      }
    }

    res.sendStatus(200);
  } catch (err) {
    console.error(err);
    res.sendStatus(500);
  }
});

// 🔥 debug route
app.get('/webhook', (req, res) => {
  res.send('WEBHOOK OK');
});

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
