## 5. Remote Access

The immich server is now set but we can't access it from outside our local network. To access photos from outside the local network while keeping the server inaccessible to everyone else, we will create a Virtual Private Network (VPN) using tailscale.

Tailscale allows us to create a VPN that behaves similar to our local network, i.e. all devices on the same VPN will be able to communicate with each other. You can read more about how tailscale works [here](https://tailscale.com/blog/how-tailscale-works).

1. **Create an account** at [https://login.tailscale.com/start](https://login.tailscale.com/start).
2. **Register the RPi**. Tailscale is already installed on the RPi. To register the RPi, call this command and follow the URL output.
   ```bash
   sudo tailscale up
   ```
3. Install the tailscale app on you phone: [https://tailscale.com/download](https://tailscale.com/download).
4. Register your phone from the tailscale app.
5. Install tailscale on other remote devices and register them in a similar way.

The [tailscale dashboard](https://login.tailscale.com/admin/machines) shows all devices registered on your VPN. To access immich remotely from a device connected to the same tailscale VPN, replace `immich.local`, or the RPi local IP, in the immich [phone](./3-immich.md#phone-app) or [web](./3-immich.md#web-app) setup with the tailscale IP or magic URI for the immich RPi, obtained from the `ADDRESSES` column.

> [!NOTE]  
> Tailscale will need to be running on devices outside the local network wishing to access immich.

> [!TIP]
> The immich app can be set up to use the local IP when you are on the home WiFi and switch to the tailscale IP otherwise. To do this go to `user icon (top right) > Settings > Networking` and enable `Automatic URL switching`.