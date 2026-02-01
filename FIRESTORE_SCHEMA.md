# Firestore Schema (recommended)

- Collection **parks** (doc id: park `id`)
  - `id` (string)
  - `name` (string)
  - `country` (string)
  - `lat` (number), `lng` (number)
  - `type` (string: thrill|water|fantasy|safari|tech)
  - `currency` (string: EUR|USD|GBP|...)
  - `entry_prices` (map: {adult:number, child:number})
  - `opening_hours` (string)
  - `thumbnail` (string URL)
  - Subcollection **attractions**
    - doc: { name:string, type:string, height_min?:number }
  - Subcollection **food**
    - doc: { name:string, price:number, category?:string }

## Security Rules (example, allow read; write for authenticated admins)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /parks/{park} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
      match /attractions/{doc} { allow read: if true; allow write: if request.auth != null && request.auth.token.admin == true; }
      match /food/{doc} { allow read: if true; allow write: if request.auth != null && request.auth.token.admin == true; }
    }
  }
}
```
