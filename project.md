Architecture

&#x20;                   +----------------------+

&#x20;                   |     GitHub Pages     |

&#x20;                   |   Flutter Web App    |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              |

&#x20;                   Firebase Authentication

&#x20;                     (Discord via OAuth)

&#x20;                              |

&#x20;       +----------------------+----------------------+

&#x20;       |                      |                      |

&#x20;       ▼                      ▼                      ▼

&#x20;  Firestore              Firebase Storage      Firebase Rules

&#x20;(user profiles)          (profile images)      (permissions)

Tech Stack

Component	Technology

Frontend	Flutter Web

State Management	Provider

Routing	GoRouter

Map	flutter\_map

Tiles	OpenStreetMap

Geocoding	Nominatim

Authentication	Firebase Authentication + Discord OAuth

Database	Firestore

Images	Firebase Storage

Hosting	GitHub Pages

CI/CD	GitHub Actions

Features

Authentication

Discord Login

First login creates a user document

User is marked as pending

Admin must approve

Only approved users can access the map



Flow:



Discord Login

&#x20;     │

&#x20;     ▼

Firebase Auth

&#x20;     │

&#x20;     ▼

Firestore



approved = false



&#x20;     │

&#x20;     ▼

Waiting for approval

Roles

ADMIN



MEMBER



PENDING



Only admins can:



approve users

remove users

promote another admin

Firestore Structure

users/

&#x20;   {uid}



settings/

&#x20;   clan



joinRequests/

User Document

{

&#x20; "uid": "...",

&#x20; "discordId": "...",

&#x20; "discordName": "Attila",

&#x20; "avatarUrl": "...",

&#x20; "country": "Hungary",

&#x20; "city": "Budapest",

&#x20; "latitude": 47.4979,

&#x20; "longitude": 19.0402,

&#x20; "approved": true,

&#x20; "role": "member",

&#x20; "createdAt": "...",

&#x20; "updatedAt": "..."

}

Pages

1\. Login

Clan logo



Login with Discord

2\. Waiting for Approval

Welcome!



Your account is awaiting approval.



Please contact a clan leader.

3\. Map



The main screen.



Contains:



interactive map

markers

search

profile drawer



Clicking a marker shows:



Avatar



Discord Name



Country



City

4\. Edit Profile



Fields:



Country

City

Avatar



The city search uses Nominatim.



When a city is selected:



save latitude

save longitude

save city

save country



If the user chooses Country only:



Country: Hungary



City: null



Latitude: country center



Longitude: country center

5\. Admin Panel



Tabs:



Pending Requests



Members



Admins



Pending example:



Attila



Approve



Reject



Members example:



Attila



Remove



Make Admin

Flutter Folder Structure

lib/



&#x20;   app/

&#x20;       app.dart

&#x20;       router.dart



&#x20;   models/

&#x20;       user.dart

&#x20;       role.dart



&#x20;   services/

&#x20;       auth\_service.dart

&#x20;       firestore\_service.dart

&#x20;       storage\_service.dart

&#x20;       geocoding\_service.dart



&#x20;   providers/

&#x20;       auth\_provider.dart

&#x20;       user\_provider.dart

&#x20;       map\_provider.dart



&#x20;   pages/

&#x20;       login/

&#x20;       waiting/

&#x20;       map/

&#x20;       profile/

&#x20;       admin/



&#x20;   widgets/

&#x20;       avatar.dart

&#x20;       member\_card.dart

&#x20;       map\_marker.dart

Firestore Security Rules

Everyone can authenticate with Discord.

Only approved members can read member profiles.

Users can update only their own profile.

Admins can approve, delete, and edit any profile.

GitHub Actions



On every push:



flutter pub get



↓



flutter test



↓



flutter build web



↓



deploy to GitHub Pages

Development Phases

Phase 1 – Project Setup

Flutter Web

Provider

GoRouter

Firebase

GitHub Pages deployment

Phase 2 – Authentication

Discord login

Session persistence

Role loading

Phase 3 – User Profiles

Firestore integration

Edit profile

Avatar upload

Phase 4 – Map

OpenStreetMap

Marker rendering

Marker clustering (optional)

User popups

Phase 5 – Location Search

Search city

Country-only option

Save coordinates

Phase 6 – Admin

Pending users

Approval

Removal

Admin promotion

Phase 7 – Polish

Responsive layout

Loading states

Error handling

Dark mode

PWA support

Optional Future Features



The architecture leaves room for additional clan features without major redesign:



Clan announcements

Discord invite link

Raid Shadow Legends player IDs

Champion showcase

Clan Boss and Hydra team sharing

Member online status

Activity feed

Localization (English/Hungarian)

Installable PWA with offline caching



This design keeps the application simple for the initial release while providing a solid foundation for future clan-management features.

