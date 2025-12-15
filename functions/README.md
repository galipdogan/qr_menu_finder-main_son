Algolia & Functions setup

1) Güvenli şekilde Algolia admin anahtarını Functions config'e ekleyin:

```bash
firebase functions:config:set algolia.admin_key="<ALGOLIA_ADMIN_KEY>" algolia.app_id="<ALGOLIA_APP_ID>" algolia.index="items_idx"
```

2) Deploy:

```bash
# functions dizinine gidin
cd functions
npm install
firebase deploy --only functions
```

3) Notlar:
- Admin anahtarını asla kod deposuna (`.env` veya kaynak kod) koymayın.
- Eğer local test yapacaksanız `firebase emulators:start` kullanın.
