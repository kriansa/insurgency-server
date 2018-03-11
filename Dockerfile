FROM kriansa/insurgency-server
LABEL maintainer="Daniel Pereira <daniel@garajau.com.br>"

# Runtime settings
ENV RCON_PASSWORD=""
ENV SV_PASSWORD=""
ENV MAPNAME="market_coop checkpoint"

# Send our custom files to the server
USER root
ADD game/cfg/* insurgency/cfg/
RUN chown -R steam:steam insurgency/cfg
USER steam

# Create the banned files to be used to store ban info
RUN touch insurgency/cfg/servervoiceban.cfg insurgency/cfg/banned_user.cfg

# Default run command
CMD ./srcds_linux -port 27015 -ip 0.0.0.0 +map $MAPNAME +maxplayers 48 \
  +rcon_password "$RCON_PASSWORD" +sv_password "$SV_PASSWORD"
