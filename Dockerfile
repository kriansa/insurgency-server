FROM kriansa/insurgency-server
LABEL maintainer="Daniel Pereira <daniel@garajau.com.br>"

# Runtime settings
ENV RCON_PASSWORD=""
ENV SV_PASSWORD=""
ENV MAPNAME="market_coop checkpoint"

USER root

# Force installation of workshop content
# sv_pure has to come first otherwise it will fail to download workshop files
# and the client will see "success failure" glowing sprites
ADD game/subscribed_file_ids.txt insurgency/
RUN su -c "./srcds_linux +sv_pure 0 -workshop +quit" steam || true

# Send our custom files to the server
ADD game/cfg/* insurgency/cfg/
ADD game/addons insurgency/addons
RUN chown -R steam:steam \
  insurgency/cfg \
  insurgency/addons \
  insurgency/subscribed_file_ids.txt
USER steam

# Run command with workshop support and tweaking it to Checkpoint Fun mode
# sv_pure and mapcyclefile have to be set on CLI
CMD ./srcds_linux -port 27015 -ip 0.0.0.0 -workshop \
   +rcon_password "$RCON_PASSWORD" +sv_password "$SV_PASSWORD" \
   +maxplayers $MAXPLAYERS +map $MAPNAME \
   +mapcyclefile "mapcycle_checkpoint.txt" +sv_pure 0
