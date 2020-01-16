#  README
Lava is an application that serves as a marketplace for people to exchange money for laundry service. Anybody can make an account, hook up some sort
of payment, and then present an order to the public market hoping that someone will fill it (do their laundry for them). 

Lava can be though of in two parts: the server and the client.

The Server:
The server is run on an iphone and contains a database that holds all of the relavant data for our app to run. This data is organized into orders and profiles. 
A profile is the medium through which a user interacts with this app. Every user has a profile. A profile object includes information about the user such as their
birthdate, their gender, and the ammount of money they have in the app. An order object is a representation of a transaction. It includes such information as the
cost of the transaction, both parties involved, and a brief description of any special needs for the order. Our database holds a table of orders and a table of
profiles that are accessed by our client through ClientRequests.

The Client:
The client accesses the server through ClientRequests. This class handles all communication with the server so that we do not have to deal with url parsing and
the like within the normal client classes. The client can be thought of from two perspectives: the perspective of the consumer, and the perspective of the supplier.
The supplier wants to make some money, so they spend most of their time on the open orders tab. On this tab, users can look through all of the currently open 
orders that do not yet have a supplier. If a user wants to do a job that they find posted in the open orders tab, they can simply click on it to see more details, 
and, if they are still interested, they can click to fill the order, therebye obligating themselves to do the described job. Upon electing to fill an order, that order is
deleted from the open orders page and then appears on the supplier's dashboard. The dashboard is the personal hub of an user. This view shows the user information
about their profile, most importantly those orders that they are responsible for filling and those orders that they themselves have posted to be filled. A user can, at
any time, click on any of these orders and choose to close them out (delete the order if they are the consumer, or indicate that they have completed their job if they
are the supplier). The dashboard also has links to information about the app, and the user's personal order history. Finally, and possibly most importantly, the user can 
create new orders from their dashboard. This is as simple as clicking the button and filling in the necessary information on the following screen. When the user clicks
the create order button, on the detail screen, they are taken back to their dashboard where they can see their new order. The new order also appears on the list of open 
orders

Extentenuations:
This is a fairly complex enterprise, and thus there is still much to do to perfect the lava experience. To be specific, there is no designated login screen at this point, as
there is only one user (me) that is hardcoded into the database. Furthermore, payments are not currently implemented. Currently the orders that a user puts on the market
show up in their open orders tab (this will not be the case in production but is necessary for demonstration purposes at this early phase); this leads to a user being able 
to be both the consumer and supplier of an order. Of course, this application is not optimized for speed, and ideally we will make fewer calls to the server in production. 
The update profile info button has not been implemented yet. This would be fairly simple, as the ClientRequests method for update profile works, but I don't know if I
will have time to get to this. The updating of profile balances is also a little buggy, but I suspect much of this issue stems from the fact that all transactions at this point
are from me to me. Of course, the UI is terrible, for I've had little time to play around with it, but this can be addressed later. Finally, the open orders tab will eventually 
need to be filtered and sectioned so that someone who wants to do laundry will see all those open orders from their dorm first, then the close ones, and then the far ones. 
I have also concluded, from all this time staring at my WSO profile picture, that I desperately need to take a new one, as I look terrifying lol. 
