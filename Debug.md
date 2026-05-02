flutter clean
flutter pub get
flutter build apk --debug
&"$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install android/app/build/outputs/apk/debug/app-debug.apk

<!-- Solution for Complex Merge Conflict -->
git checkout main
git pull origin main

git fetch origin pull/26/head:pr-26
git merge --no-ff pr-26   # conflicts may happen here
# resolve conflicts, then:
git add -A
git commit
git push origin main
git push -u origin pr-26