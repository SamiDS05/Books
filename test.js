const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const server = express();
const port = 8081;

server.use(bodyParser.urlencoded({extended: false}));
server.use(bodyParser.json());

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'cimatec',
    database: 'crud_node'
});

db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('Conectado com Sucesso ao Banco de Dados!');
});



server.get('/', function(req, res){
    res.sendFile(__dirname + '/books.html');
});



server.post('/books', (req, res) => {
    const { nome, autor, ano, genero } = req.body;
    const query = 'INSERT INTO books (nome, autor, ano, genero) VALUES (?, ?, ?, ?)';
    db.query(query, [nome, autor, ano, genero], (error, results) => {
        if (error) {
            return res.status(500).json({ error });
        }
        res.json({message: 'Dados inseridos!'})
    });
});


server.get('/searchBooks', (req, res) =>{

    const query = 'SELECT * FROM books'

    db.query(query, (error, results) => {
        if (error) {
            throw err;
        }
        res.json(results);
    });

})


server.put('/updateBooks/:idbooks', (req,res) =>{

 const {idbooks} = req.params
 const {nome, autor, ano, genero} = req.body   
 const query = 'UPDATE books SET nome = ?, autor = ?, ano = ?, genero = ? WHERE idbooks = ?'

 db.query(query, [nome, autor, ano, genero, idbooks], (err,results) => {

if(err){

    throw err
}

res.json({message: 'Dados atualizados!'})

 })
})

server.delete('/deleteBooks/:idbooks', (req,res) => {

    const {idbooks} = req.params
    const query = 'DELETE FROM books WHERE idbooks = ?'
   
    db.query(query, [idbooks], (err,results) => {
   
   if(err){
   
       throw err
   }
   
   res.json({message: 'Dados deletados!'})
   
    })
    
})


server.listen(port, () => {
    console.log(`Servidor está rodando na porta ${port}`);
});
