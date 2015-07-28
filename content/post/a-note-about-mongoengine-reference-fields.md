---
Categories:
- Development
- mongoengine
Description: memory leaks...
Tags:
- mongo
- python
date: 2014-11-20T01:28:25-07:00
title: a note about mongoengine reference fields
---

Recently at my work we ran into some memory issues with parts of our code; a flask app utilizing mongodb primarily via mongoengine.

Mongoengine itself is pretty cool; I wouldn't define it as an ORM, but rather a framework for handling mongodb data as code.

What you do is define document *classes*, each of which gets its own collection, and in these classes you define the fields of the document.
```python
from mongoengine import Document, StringField, IntField, ListField

class Person(Document):
	name = StringField()
    age = IntField()
    friends = ListField(StringField())
    ...
```

Then the querying logic exists as classmethods on the document class, leading to some pretty clean syntax.
```python
all_the_people = Person.objects
# Filter queries always return a list
Travis = Person.objects(name="Travis")[0]
```

Querying can get pretty complicated, but I feel it does a good job of staying very readable. Read more on querying logic [here](http://docs.mongoengine.org/guide/querying.html#querying-the-database).

When you query said collection instead of getting some json, or dict, or whatever back, you instead get an instance of the document's class. This allows you to stay object orientated with commonly used infered data, or operational logic associated with certain data, etc.
```python
class Person(Document):
	...
    def first_friend(self):
    	return self.friends[0]
```
# We can use .first() on a query to shortcut the previous method (or return none instead of an index error)
```python
Travis = Person.objects(name="Travis").first()
print(Travis.first_friend())
```
Now the really cool part. Mongoengine supports this idea of a *reference field*, a field which contains a pointer to another mongodb document, which it will automagically (and lazily) dereference for you.
```python
from mongoengine import ... ReferenceField

class Person(Document):
	...
    friends = ListField(ReferenceField())
    ...

Travis = Person.objects(name="Travis").first()
Will = Travis.first_friend()
print(Will.name)
```

This is really cool. But because of the way it's implimented, you might run into issues you didn't think about. Because reference fields are *lazily* dereferenced, you usually don't have to worry too much about their memory overhead, but to prevent a crazy number of database calls, they *are* cached once dereferenced. Consider the following code:
```python
Travis = Person.objects(name="Travis").first()
for person in Travis.friends:
	pass
```

Each loop mongoengine will call to mongodb and dereference one of my friends, it then stores this result on `Travis`, as well as copies it to a new `Person` object which gets (briefly) assigned to `person`. At the end of this *all* of my friends will exist in memory on the `Travis` object, on the up side this means the next time I reference a friend there's no database call:
```python
Travis = Person.objects(name="Travis").first()
# This does a database call to mongodb
Will = Travis.friends[0]
# This just copies from memory, no network call at all
AlsoWill = Travis.friends[0]
```
On the down side, the object `Travis` is now larger. If we assume all `Person` objects are the same size, then at then end of this:
```python
Travis = Person.objects(name="Travis").first()
Travis.friends[0]
```
`Travis` now takes up twice the space in ram, if you have a lot of friends:
```python
You = Person.objects(name="John").first()
len(You.friends)
>>> 200
for friend in You.friends:
	pass
```
`You` now takes up 200 times the space in ram after that loop, this memory will not be release until either: the parent object is deleted (or it's scope removed), or you `.reload()` it.
```python
You.reload()
```
`.reload()` on a mongoengine `Document` deletes it's in memory model and reloads it from the database (this does include a network call, so depending you may need to watch for latency).

###Update:
Turns out, there's actually an official solution to this.
```python
for friend in You.friends.no_cache():
    pass
```
Adding `.no_cache()` to the end of a queryset does exactly what it sounds like; disables the caching. So for large loops when you don't re-use the items later, you should practice using this option. Keep in mind however that this caching is generally a good idea to keep around when accessing more constrained sets of data; if you re-access the same data twice even once, it's likely worth it.
