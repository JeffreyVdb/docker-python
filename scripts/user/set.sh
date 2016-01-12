#!/usr/bin/env bash

OLD_USERNAME="$1"
echo "Changing user: $OLD_USERNAME..."

OLD_UID=$(id -u)
NEW_UID="$2"
echo "NEW_UID: $NEW_UID"

OLD_GID=$(id -g)
NEW_GID="$3"
echo "NEW_GID: $NEW_GID"

NEW_USERNAME="$4"
echo "NEW_USERNAME: $NEW_USERNAME"

if [ -n "${NEW_UID+set}" ] && [ -n "${NEW_GID+set}" ];
then
    # Update group id
    echo "Changing groupid to $NEW_GID..."
    groupmod -g ${NEW_GID} ${OLD_USERNAME}

    # Update user id
    echo "Changing userid to $NEW_UID..."
    usermod -u ${NEW_UID} ${OLD_USERNAME}

    # Update file permissions
    echo "Changing file permissions in ${ROOT}..."
    find ${ROOT} -uid ${OLD_UID} -exec chown ${NEW_UID}:${NEW_GID} {} +
fi

if [ -n "${NEW_USERNAME+set}" ];
then
    # Update username and move home directory
    echo "Changing username to $NEW_USERNAME..."
    usermod --login ${NEW_USERNAME} \
        --move-home \
        --home /home/${NEW_USERNAME} \
        ${OLD_USERNAME}

    echo "Changing file permissions in /home/${NEW_USERNAME}..."
    find /home/${NEW_USERNAME} -uid ${OLD_UID} -exec chown ${NEW_UID}:${NEW_GID} {} +

    # Update sudoers
    sed -i "s/$OLD_USERNAME/$NEW_USERNAME/g" /etc/sudoers
fi
