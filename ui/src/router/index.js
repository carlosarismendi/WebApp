import Vue from 'vue';
import VueRouter from 'vue-router';

import UTILS from '@/utils'
// import store from '@/store'

import MainLayout from '../components/layouts/MainLayout';
import AuthLayout from '../components/layouts/AuthLayout';

import Errors from '../views/Errors/Errors';

import Home from '../views/Home';
import Users from '../views/Users';
import Profile from '../views/Profile';
import NewPost from '../views/NewPost';
import AccountSettings from '../views/AccountSettings';

import SignIn from '../views/Auth/SignIn';
import SignUp from '../views/Auth/SignUp';

Vue.use(VueRouter);

const usersRoutes = (prop) => [
  {
    path: '/sign-in',
    name: prop + '.sign-in',
    meta: { public: true },
    component: SignIn
  },
  {
    path: '/sign-up',
    name: prop + '.sign-up',
    meta: { public: true },
    component: SignUp
  }
]

const childRoutes = (prop) => [
  {
    path: '/',
    redirect: 'home'
  },
  {
    path: 'home',
    name: prop + '.home',
    meta: { private: true },
    component: Home
  },
  {
    path: 'users',
    name: prop + '.users',
    meta: { private: true },
    component: Users
  },
  {
    path: 'account-settings',
    name: prop + '.account-settings',
    meta: { private: true },
    component: AccountSettings
  },
  {
    path: 'profile/:id',
    name: prop + '.profile',
    meta: { private: true },
    component: Profile
  },
  {
    path: 'new-post',
    name: prop + '.new-post',
    meta: { private: true },
    component: NewPost
  },
  {
    path: 'errors/:error',
    name: prop + '.errors',
    meta: { public: true },
    component: Errors
  }
]

const routes = [
  {
    path: '/',
    name: 'app',
    component: MainLayout,
    children: childRoutes('app')
  },
  {
    path: '/users',
    name: 'users',
    component: AuthLayout,
    meta: { public: true },
    children: usersRoutes('users')
  },
];

const router = new VueRouter({
  mode: 'history',
  base: process.env.VUE_APP_BASE_URL,
  routes
});

router.beforeEach((to, from, next) => {
  if (to.meta.public || (to.meta.private && UTILS.user.isAuthenticated())) {
    next()
  } else {
    UTILS.user.removeLogin()
    next('/sign-in')
  }
})

export default router;
