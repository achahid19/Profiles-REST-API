from django.contrib import admin
from profiles_api import models

# Register your models here.
admin.site.register(models.UserProfile) # tells Dango admin to register our user profile model with the admin,
                                            # so it makes it accessible through the admin interface
admin.site.register(models.ProfileFeedItem)
