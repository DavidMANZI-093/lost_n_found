import typing

def Cleaner(cursor: typing.Any):
    cursor.execute("DELETE FROM lost_n_found.lost_item")
    cursor.execute("DELETE FROM lost_n_found.found_item")
    cursor.execute("DELETE FROM lost_n_found.user")
    cursor.close()
