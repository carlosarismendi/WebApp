const request = require('request');
var faker = require('faker');
const FormData = require('form-data');
const axios = require('axios');
const fs = require('fs')
axios.defaults.baseURL = 'http://localhost:3000/api/';

const OPERATION = 'create' // users 'read' or 'create'
const RESOURCE = 'posts' // create 'posts' or 'follows'
const MAX_USERS = 50
const MAX_POST_PER_USER = 10
const MAX_FOLLOWS_PER_USER = MAX_USERS - 10

const setHeaders = function (user) {
    axios.defaults.headers.common['Authorization'] = `Bearer ${user.jwtToken}`
}


let userArray = []

const newUser = function () {
    const nickname = `${faker.internet.userName()}${faker.random.number()%MAX_USERS+1}`
    let user = {
        email: faker.internet.email(),
        nickname: nickname,
        password: nickname,
        name: `${faker.name.firstName()} ${faker.name.lastName()}`
    }

    return user
}

const login = async function (user) {
    await axios.post('login', { user: user.nickname, password: user.password })
        .then((res) => {
            if (res.data.status < 0) {
                console.log(res.data.data.error)
                return res.data.status
            } else {
                user.jwtToken = res.data.data.jwtToken
                user.idUser = res.data.data.idUser
                return user
            }
        }).catch((err) => {
            // console.log(err)
        }).finally(() => {

        })

}

const registerUser = async function (user) {
    await axios.post('registers', user)
        .then((res) => {
            if (res.data.status < 0) {
                console.log(res.data.data.error)
                return res.data.status
            } else {
                user.confirmToken = res.data.data.token
                return user
            }
        }).catch((err) => {
            console.log(err)
        }).finally(() => {

        })
}

const confirmAccount = async function (user) {
    await axios.put('register', { token: user.confirmToken })
        .then((res) => {
            if (res.data.status < 0) {
                console.log(res.data.data.error)
                return res.data.status
            }
        }).catch((err) => {
            console.log(err)
        }).finally(() => {

        })
}

const createUsers = async function () {
    for (let i = 0; i < MAX_USERS; i++) {
        try {
            let user = newUser()

            await registerUser(user)
            // await confirmAccount(user)
            await login(user)

            userArray.push(user)
        } catch (err) {
            console.log(err)
        }
    }
}

const readUsers = async function () {
    userArray = []

    let user = newUser()
    user.nickname = 'Isobel2613'
    user.password = user.nickname

    await login(user)

    if (!user.jwtToken) {
        throw "Error: No se pudo iniciar sesión con el usuario indicado en readUsers(...) en faker.js."
    }

    setHeaders(user)

    await axios.get('users')
        .then((res) => {
            if (res.data.status < 0) {
                console.log(res.data.data.error)
                return res.data.status
            }

            if (res.data.data && res.data.data.users) {
                if (Array.isArray(res.data.data.users)) {
                    userArray = userArray.concat(res.data.data.users)
                } else {
                    userArray.push(res.data.data.users)
                }
            }

            userArray.forEach(item => {
                item.password = item.nickname
            })
        }).catch((err) => {
            console.log(err)
        }).finally(() => {

        })
}

const createFollow = async function (userFollowed) {
    const params = {
        idUserFollowed: userFollowed.idUser
    }

    await axios.post('follows', params)
        .then((res) => {
            if (res.data.status < 0) {
                console.log(res.data.data.error)
                return res.data.status
            }
        }).catch((err) => {
            console.log(err)
        }).finally(() => {

        })
}

const createFollows = async function () {
    for(let i = 0; i < MAX_USERS; i++) {
        const userFollower = userArray[i]
        await login(userFollower)

        if (!userFollower.jwtToken) continue

        setHeaders(userFollower)
        for(let j = 0; j < MAX_FOLLOWS_PER_USER; j++) {
            if (i === j) continue

            const follow = Math.floor(Math.random() * 2)

            if (follow) {
                await createFollow(userArray[j])
            }
        }
    }
}

const createPost = async function (user, imageData, imgName) {
    const text = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry'
    const randLenght = new Date().getTime() % text.length

    const rand = Math.random() % 2
    const description = (rand != 0) ? text.substring(0, randLenght) : null

    var formData = {
        description: description,
        image: {
            value:  imageData,
            options: {
                filename: imgName,
                contentType: 'image/jpg',
                mimetype: 'image/jpg'
            }
        }
    };

    request.post({url:'http://localhost:3000/api/posts', formData: formData, headers: {
        Authorization: `Bearer ${user.jwtToken}`
    }}, function optionalCallback(err, httpResponse, body) {
        if (err) {
            console.error('upload failed:', err);
        }
    });
}

const createPosts = async function () {
    for(let i = 0; i < MAX_USERS; i++) {
        const user = userArray[i]
        await login(user)

        if (!user.jwtToken) continue

        setHeaders(user)
        for(let j = 1; j <= MAX_POST_PER_USER; j++) {
            const rand = Math.random() % 2

            if (rand != 0) {
                image = fs.readFileSync(`./fakerFiles/imgs/${j}.jpg`)
                await createPost(userArray[i], image, `${j}`)
            }
        }
    }
}

const main = async function () {
    if (OPERATION === 'create') {
        await createUsers()
    } else {
        await readUsers()
    }

    if (RESOURCE === 'posts') {
        await createPosts()
    } else {
        await createFollows()
    }
}

main()