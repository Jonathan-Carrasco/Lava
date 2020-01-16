from django.db import models

class Profile(models.Model):
    name = models.CharField(max_length=100)#the user's actual name
    handle = models.CharField(max_length=100)#the user's unique string identifier
    profile_picture = models.ImageField()
    dob = models.DateField()
    email = models.EmailField()
    cell_number = models.IntegerField()
    rating = models.IntegerField()#don't know if integer is a thing here
    active_orders = models.CharField(max_length=500, default='')#a set of integers where each integer accesses an active order in the order database
    history = models.CharField(max_length=1000, default='')#all of these orders include time windows where the end of the window has already passed.
    payment_info = models.CharField(max_length=1000, default='')#A list of integers where each int accesses a valid_payment in the valid_payment database. valid_payment objects consist of info pertaining to a certain form of payment (ex. bank account, credit card, paypal, etc)
    account_balance = models.IntegerField()#This is the amount of money that the profile owner has in his or her account either put there by use of a valid_payment or earned as a provider; also note that I don't know what the deal is with integers here
    verified_provider = models.BooleanField()

    def __str__(self):
        return self.name + ':' + self.handle

class Valid_Payment(models.Model):
    venmo = 've'
    square_cash = 'sq'
    card = 'ca'
    paypal = 'pa'
    
    payment_choices = (
        (venmo, 've'),
        (square_cash, 'sq'),
        (card, 'ca'),
        (paypal, 'pa'),
    )
    
    payment_type = models.CharField(max_length=2, choices=payment_choices, default=card)
    card_number = models.CharField(max_length=16, default='')
    name_on_card = models.CharField(max_length=100, default='')
    expiration_date = models.CharField(max_length=8, default='')
    ccv = models.CharField(max_length=3, default='')
    handle = models.CharField(max_length=100, default='')
    
    
class Order(models.Model):
    consumer = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='+')
    provider = models.ForeignKey(Profile, on_delete=models.CASCADE, related_name='+')
    pickup_start_time = models.DateTimeField()
    pickup_end_time = models.DateTimeField()
    dropoff_start_time = models.DateTimeField()
    dropoff_end_time = models.DateTimeField()
    value = models.IntegerField()#the cost of the order
    location = models.CharField(max_length=100)#for starters this will just be a dorm and room number at Williams
    completed = models.BooleanField()#true if the order has been completed
    review_completed = models.IntegerField()#0 if neither review, 1 if only consumer, 2 if only provider, 3 if both
    description = models.CharField(max_length=500)#a description of special aspects of the order
    
