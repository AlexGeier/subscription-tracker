Group Project - README Template
===

# EzSub

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)
2. [Video Walkthrough](#Video-Walkthrough)

## Overview
### Description
Allows users to keep track of and manage all of their monthly subscriptions and recurring payments.

### App Evaluation
   - **Category:** Utility
   - **Mobile:** Many mobile apps use the subscription model. Being able to view all of your subscriptions on the mobile device you access these apps from can be very convenient
   - **Story:** Monthly subscription services are a essential part of our lives now. On top of basic utility bills such as electricity and phone bill, we pay monthly subscription for bunch of other servies. i.e. Netflix, Spotify, etc. This app could help the users keep track of the recurring payments
   - **Market:** Many people are subscribed to at least four or five monthly services these days, and most of them will be due on different days. This app will be appealing to the general public who are responsible for their own bills.
   - **Habit:** Knowing exactly how much money you owe each month can be extremely important, so users may want to check the app frequently to get the most up to date amount
   - **Scope:** V1 will allow users to setup accounts as well as add and view their subscriptions. V2 will allow users to see their subscriptions in a calendar view. V3 will allow users to receive notifications before payments are due.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* As a user, I should be able to create an account
* As a user, I should be able to add an email address to my account
* As a user, I should be able to remove an email address from my account
* As a user, I should be able to sign in to my account
* As a user, I should be able to sign out of my account
* As a user, I should be able to see a list of my subscriptions
* As a user, I should be able to see when each subscription payment is due
* As a user, I should be able to see how much money is due for each payment
* As a user, I should be able to delete a subscription from the app
* As a user, I should be able to see the total amount of money I pay each month
* As a user, I should have the option to add a subscription with a dynamic monthly payment
* As a user, I should have the option to create a subscription with a fixed monthly payment
* As a user, I should be able to see the total amount I've spent on a susbscription
* As a user, I should be able to see the average amount I've spent on dynamic susbscriptions

**Optional Nice-to-have Stories**

* As a user, I should be notified before a subscription payment is due
* As a user, I should be able to toggle notifications on and off
* As a user, I should be able to click a link that opens a browser and directs me to a page which allows me to manage each of my subscriptions

### 2. Screen Archetypes

* Sign in page
   * (finished) As a user, I should be able to sign in to my account
* Register page
   * (finished) As a user, I should be able to create an account
   * (finished) As a user, I should be able to add an email address to my account
* Subscription List Page
    * (finished) As a user, I should be able to see a list of my subscriptions
    * As a user, I should be able to see when each subscription payment is due
    * As a user, I should be able to see how much money is due for each payment
    * As a user, I should be able to delete a subscription from the app
    * (finished) As a user, I should be able to see the total amount of money I pay each month
* Subscription Detail Page
    * (finished) As a user, I should be able to see the total amount I've spent on a susbscription
    * As a user, I should be able to see the average amount I've spent on dynamic susbscriptions
* Add a subscription page
    * (finished) As a user, I should have the option to add a subscription with a dynamic monthly payment
    * (finished) As a user, I should have the option to create a subscription with a fixed monthly payment
* Settings Page
    * (finished) As a user, I should be able to sign out of my account
    * As a user, I should be notified before a subscription payment is due
    * As a user, I should be able to toggle notifications on and off

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Subscription list tab
* Calendar tab
* Settings tab

**Flow Navigation** (Screen to Screen)

* Sign in page
    * Register Page
    * Subscription List page

* Subscription List page
   * Add a subscription page
   * Subscription detail page
* Calendar View
    * Subscription detail page
* Settings page
    * Sign in page (on sign out)
    * As a user, I should be able to remove an email address from my account

## Wireframes
![Wireframe](wireframe.jpeg)

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
### Models
#### User

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | id            | UUID     | unique id for the user (default field) |
   | email         | String   | The user’s email address |
   | firstName     | String   | The user’s first name |
   | lastName      | String   | The user's last name |

#### Fixed amount Subscription

   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | id            | UUID     | The subscription’s id |
   | serviceName         | String   | Name of the subscribed service  |
   | moneyDue     | Float  | Amount that’s due monthly |
   | dueDate      | Datetime   | When it’s due |
   | startDate      | Datetime   | The day the subscription started |
   
#### Dynamic amount Subscription
   | Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | id            | UUID     | The subscription’s id |
   | serviceName         | String   | Name of the subscribed service  |
   | averageAmount     | Float  | The average cost of this subscription in the past |
   | projectedAmount     | Float  | What the current period’s projected cost is |
   | totalAmount     | Float  | The total cost of this subscription so far |
   | dueDate      | Datetime   | When it’s due |
   | startDate     | Datetime   | The day the subscription started |

### Networking
#### List of network requests by screen
We're still debating on which network to use, either Firebase or Parse. Our group members have different ideas, so currently we don't have any Code Snippets.
   - Home Page
      - (READ/GET) Get a list of the user’s current subscriptions
      - (CREATE/POST) Create a new subscription
      - (DELETE) Delete a subscription from the list
   - Subscription Detail Page
      - (READ/GET) Get more details about the selected subscription
   - Calendar Page
      - (READ/GET) Get a list of the user’s current subscriptions
   - Sign in Page
      - (READ/POST) Attempt to sign in to the user’s account
   - Sign Up Page
      - (CREATE/POST) Attempt to create a new account
   - Settings Page
      - (CREATE/POST) Add a new email to scan subscriptions from
      - (DELETE) No longer scan subscriptions from an email account
      
      
      
## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://g.recordit.co/wfyeKhIOr0.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />
<img src='https://i.imgur.com/ND3yiLI.gif'  title='Video Walkthrough' width='' alt='Video Walkthrough' />
   
