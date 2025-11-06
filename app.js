// Express
const express = require('express');
const app = express();
app.use(express.json());
app.use(express.urlencoded({extended: true}));
app.use(express.static('public'));

const PORT = 8409;

// Database
const db = require('./database/db-connector');

//Handlebars
const { engine } = require('express-handlebars');
app.engine('.hbs', engine({ extname: '.hbs' }));
app.set('view engine', '.hbs');

// Route Handlers

// Read Routes
app.get('/', async function (req, res) {
	try {
		res.render('home');
	} catch (error) {
		console.error('Error rendering page:', error);
		res.status(500).send('An error occurred while renering the page.');
	}
});

app.get('/Customers', async function (req, res) {
	try {
		const query1 = `SELECT Customers.customerID, Customers.firstName, Customers.lastName, \
			Customers.address, Customers.phone FROM Customers;`;
		const [customer] = await db.query(query1);
		
		res.render('customers', { customer: customer });
	} catch (error) {
		console.error('Error executing queries:', error);
		res.status(500).send(
			'An error occured while executing the atabase queries.'
		);
	}
});

// Listener

app.listen(PORT, function() {
	console.log(
		'Express started on http://localhost:' +
			PORT +
			'; press Ctrl-C to terminate.'
	);
});
