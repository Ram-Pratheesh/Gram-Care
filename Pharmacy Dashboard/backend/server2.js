const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
const dotenv = require('dotenv');
const bcrypt = require('bcrypt');

dotenv.config();

const app = express();
const PORT = 4000;

app.use(cors());
app.use(express.json());

// MongoDB setup
//const client = new MongoClient("mongodb+srv://ajayrsrinivas:6220@cluster0.hhfc8.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0");
const client = new MongoClient("mongodb+srv://anirudhchandrasekaran_db_user:thbDXCQPgiUayhZa@gramcare.wgfq5mx.mongodb.net/?retryWrites=true&w=majority&appName=GramCare");
let usersCollection;

//ATLAS_URI=mongodb+srv://anirudhchandrasekaran_db_user:thbDXCQPgiUayhZa@gramcare.wgfq5mx.mongodb.net/?retryWrites=true&w=majority&appName=GramCare
//DB_NAME=gramcare
//COLLECTION_NAME=patients
//PORT=4000
// async function connectDB() {
//   try {
//     await client.connect();
//     const db = client.db('gramcare');
//     usersCollection = db.collection('pharmacies');
//     console.log('MongoDB connected');
//   } catch (err) {
//     console.error(err);
//   }
// }
// connectDB();
async function connectDB() {
  try {
    await client.connect();
    const db = client.db('gramcare');
    usersCollection = db.collection('pharmacies');
    console.log('MongoDB connected');
  } catch (err) {
    console.error(err);
  }
}
connectDB();

// Signup route
// app.post('/api/signup', async (req, res) => {
//   const { username, email, password } = req.body;

//   if (!username || !email || !password) {
//     return res.status(400).json({ message: 'All fields are required.' });
//   }

//   const existingUser = await usersCollection.findOne({ email });
//   if (existingUser) {
//     return res.status(400).json({ message: 'Email already registered.' });
//   }

//   const hashedPassword = await bcrypt.hash(password, 10);

//   await usersCollection.insertOne({ username, email, password: hashedPassword });
//   res.status(201).json({ message: 'User registered successfully!' });
// });

//Login route
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'All fields are required.' });
  }

  const user = await usersCollection.findOne({ email });
  if (!user) {
    return res.status(400).json({ message: 'User not found.' });
  }

  const match = await bcrypt.compare(password, user.password);
  if (!match) {
    return res.status(400).json({ message: 'Invalid password.' });
  }

  res.status(200).json({ message: 'Login successful!', username: user.username });
});

// server.js (login endpoint example)
// app.post('/api/pharmacylogin', async (req, res) => {
//   const { email, password } = req.body;
//   const db = client.db("gramcare");
//   const pharmacy = await db.collection("pharmacies").findOne({ email, password });

//   if (!pharmacy) {
//     return res.status(401).json({ message: "Invalid login" });
//   }

//   // send back pharmacy identifier
//   res.json({
//     message: "Login successful",
//     email: pharmacy.email,
//     pharmacyId: pharmacy._id
//   });
// });
// Signup route
app.post('/api/signup', async (req, res) => {
  const { username, pharmacyName, address, contactNumber, email, password } = req.body;

  if (!username || !pharmacyName || !address || !contactNumber || !email || !password) {
    return res.status(400).json({ message: 'All fields are required.' });
  }

  const existingUser = await usersCollection.findOne({ email });
  if (existingUser) {
    return res.status(400).json({ message: 'Email already registered.' });
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  await usersCollection.insertOne({
    username,
    pharmacyName,
    address,
    contactNumber,
    email,
    password: hashedPassword
  });

  res.status(201).json({ message: 'Pharmacy registered successfully!' });
});
// Profile route
app.get('/api/profile', async (req, res) => {
  const email = req.query.email;
  if(!email) return res.status(400).json({ message: 'Email is required' });

  const user = await usersCollection.findOne({ email }, { projection: { password: 0 } });
  if(!user) return res.status(404).json({ message: 'User not found' });

  res.status(200).json(user);
});

// Inventory collection
let inventoryCollection;

async function connectDB() {
  try {
    await client.connect();
    const db = client.db('pharmacyDB');
    usersCollection = db.collection('pharmacies');
    inventoryCollection = db.collection('pharm_inventory'); // ✅ new
    console.log('MongoDB connected');
  } catch (err) {
    console.error(err);
  }
}

// Add stock
app.post('/api/inventory', async (req, res) => {
  const { email, itemName, category, quantity, restockDate } = req.body;
  if (!email || !itemName || !category || !quantity || !restockDate) {
    return res.status(400).json({ message: "All fields are required" });
  }

  await inventoryCollection.insertOne({ email, itemName, category, quantity, restockDate });
  res.status(201).json({ message: "Stock added successfully" });
});

// Fetch stock by pharmacy email
app.get('/api/inventory', async (req, res) => {
  const email = req.query.email;
  if (!email) return res.status(400).json({ message: "Email required" });

  const items = await inventoryCollection.find({ email }).toArray();
  res.status(200).json(items);
});



app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
//works
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// const express = require('express');
// const cors = require('cors');
// const { MongoClient } = require('mongodb');
// const dotenv = require('dotenv');
// const bcrypt = require('bcrypt');

// dotenv.config();

// const app = express();
// const PORT = 4000;

// app.use(cors());
// app.use(express.json());

// // MongoDB connection
// const client = new MongoClient("mongodb+srv://ajayrsrinivas:6220@cluster0.hhfc8.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0");
// let pharmacyCollection;

// async function connectDB() {
//   try {
//     await client.connect();
//     const db = client.db('mydb');
//     pharmacyCollection = db.collection('pharmacies');
//     console.log('MongoDB connected');
//   } catch (err) {
//     console.error(err);
//   }
// }
// connectDB();

// // Pharmacy signup
// app.post('/api/pharmacy-signup', async (req, res) => {
//   const {
//     pharmacyName, ownerName, drugLicense, taxId, address,
//     pincode, district, state, contactNumber, email, username, password
//   } = req.body;

//   if (!pharmacyName || !ownerName || !drugLicense || !taxId || !address ||
//       !pincode || !district || !state || !contactNumber || !email || !username || !password) {
//     return res.status(400).json({ message: 'All fields are required.' });
//   }

//   const existingUser = await pharmacyCollection.findOne({ email });
//   if (existingUser) return res.status(400).json({ message: 'Email already registered.' });

//   const hashedPassword = await bcrypt.hash(password, 10);

//   await pharmacyCollection.insertOne({
//     pharmacyName, ownerName, drugLicense, taxId, address,
//     pincode, district, state, contactNumber, email, username, password: hashedPassword
//   });

//   res.status(201).json({ message: 'Pharmacy registered successfully!' });
// });

// // Pharmacy login
// app.post('/api/pharmacy-login', async (req, res) => {
//   const { email, password } = req.body;

//   if(!email || !password) return res.status(400).json({ message: 'All fields are required.' });

//   const user = await pharmacyCollection.findOne({ email });
//   if(!user) return res.status(400).json({ message: 'User not found.' });

//   const match = await bcrypt.compare(password, user.password);
//   if(!match) return res.status(400).json({ message: 'Invalid password.' });

//   res.status(200).json({ message: 'Login successful!', pharmacyName: user.pharmacyName });
// });

// app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));


// const express = require('express');
// const cors = require('cors');
// const { MongoClient } = require('mongodb');
// const dotenv = require('dotenv');
// const bcrypt = require('bcrypt');

// dotenv.config();

// const app = express();
// const PORT = 4000;

// app.use(cors());
// app.use(express.json());

// // MongoDB setup
// const client = new MongoClient("mongodb+srv://ajayrsrinivas:6220@cluster0.hhfc8.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0");
// let pharmacyCollection;

// async function connectDB() {
//   try {
//     await client.connect();
//     const db = client.db('pharmacyDB');
//     pharmacyCollection = db.collection('pharmacies');
//     console.log('MongoDB connected');
//   } catch (err) {
//     console.error(err);
//   }
// }
// connectDB();

// // Pharmacy Signup
// app.post('/api/pharmacysignup', async (req, res) => {
//   const { pharmacyName, ownerName, taxId, contactNumber, email, username, password } = req.body;

//   if (!pharmacyName || !ownerName ||!taxId || !contactNumber || !email || !username || !password) {
//     return res.status(400).json({ message: 'All fields are required.' });
//   }

//   const existingUser = await pharmacyCollection.findOne({ email });
//   if (existingUser) {
//     return res.status(400).json({ message: 'Email already registered.' });
//   }

//   const hashedPassword = await bcrypt.hash(password, 10);

//   await pharmacyCollection.insertOne({
//     pharmacyName,
//     ownerName,
//     taxId,
//     contactNumber,
//     email,
//     username,
//     password: hashedPassword
//   });

//   res.status(201).json({ message: 'Pharmacy registered successfully!' });
// });

// // Optional: Pharmacy Login
// app.post('/api/pharmacylogin', async (req, res) => {
//   const { email, password } = req.body;

//   const user = await pharmacyCollection.findOne({ email });
//   if (!user) return res.status(400).json({ message: 'User not found.' });

//   const match = await bcrypt.compare(password, user.password);
//   if (!match) return res.status(400).json({ message: 'Invalid password.' });

//   res.status(200).json({ message: 'Login successful!', pharmacyName: user.pharmacyName });
// });

// app.get('/api/pharmacy/:id', async (req, res) => {
//   try {
//     const col = getCollectionByUserType("Pharmacy");
//     const user = await col.findOne({ _id: new ObjectId(req.params.id) });
//     if (!user) return res.status(404).json({ message: "Not found" });
//     delete user.password;
//     res.json(user);
//   } catch (e) {
//     res.status(500).json({ message: "Error fetching profile" });
//   }
// });


// app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
